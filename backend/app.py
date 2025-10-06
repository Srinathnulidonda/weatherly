import os
import sys
import json
import time
import uuid
import logging
import requests
from datetime import datetime, timedelta
from functools import wraps
from typing import Dict, Any, Optional, Tuple

from flask import Flask, jsonify, request, g
from flask_cors import CORS
from flask_limiter import Limiter
from flask_limiter.util import get_remote_address
from flask_caching import Cache
from werkzeug.exceptions import HTTPException
from werkzeug.middleware.proxy_fix import ProxyFix
from dotenv import load_dotenv

load_dotenv()

class Config:
    ENV = os.getenv('FLASK_ENV', 'production')
    DEBUG = ENV == 'development'
    TESTING = ENV == 'testing'
    
    WEATHER_API_KEY = os.getenv('WEATHER_API_KEY')
    if not WEATHER_API_KEY:
        raise ValueError("WEATHER_API_KEY environment variable is required")
    
    WEATHER_API_BASE_URL = 'https://api.openweathermap.org/data/2.5'
    WEATHER_API_TIMEOUT = 10
    
    REDIS_URL = os.getenv('REDIS_URL', 'redis://localhost:6379/0')
    
    CACHE_TYPE = 'simple'
    CACHE_DEFAULT_TIMEOUT = 300
    CACHE_KEY_PREFIX = 'weather_app'
    
    RATELIMIT_STORAGE_URL = REDIS_URL
    RATELIMIT_DEFAULT = "100 per hour"
    RATELIMIT_HEADERS_ENABLED = True
    
    CORS_ORIGINS = os.getenv('CORS_ORIGINS', '*').split(',')
    
    SECRET_KEY = os.getenv('SECRET_KEY', 'dev-secret-key-change-in-production')
    MAX_CONTENT_LENGTH = 1 * 1024 * 1024
    
    LOG_LEVEL = os.getenv('LOG_LEVEL', 'INFO')
    LOG_FORMAT = '%(asctime)s - %(name)s - %(levelname)s - %(message)s'
    
    ENABLE_METRICS = os.getenv('ENABLE_METRICS', 'true').lower() == 'true'

logging.basicConfig(
    level=getattr(logging, Config.LOG_LEVEL),
    format=Config.LOG_FORMAT,
    handlers=[
        logging.StreamHandler(sys.stdout)
    ]
)

logging.getLogger('werkzeug').setLevel(logging.WARNING)
logging.getLogger('urllib3').setLevel(logging.WARNING)

logger = logging.getLogger(__name__)

app = Flask(__name__)
app.config.from_object(Config)

CORS(app, 
     origins=app.config['CORS_ORIGINS'],
     allow_headers=['Content-Type', 'Authorization', 'X-Request-ID'],
     expose_headers=['X-Request-ID', 'X-RateLimit-Limit', 'X-RateLimit-Remaining'],
     supports_credentials=True)

cache = Cache(app, config={
    'CACHE_TYPE': app.config['CACHE_TYPE'],
    'CACHE_DEFAULT_TIMEOUT': app.config['CACHE_DEFAULT_TIMEOUT'],
    'CACHE_KEY_PREFIX': app.config['CACHE_KEY_PREFIX']
})

limiter = Limiter(
    app=app,
    key_func=get_remote_address,
    default_limits=[app.config['RATELIMIT_DEFAULT']],
    headers_enabled=app.config['RATELIMIT_HEADERS_ENABLED']
)

app.wsgi_app = ProxyFix(app.wsgi_app, x_for=1, x_proto=1, x_host=1, x_prefix=1)

@app.before_request
def before_request():
    g.request_id = request.headers.get('X-Request-ID', str(uuid.uuid4()))
    g.start_time = time.time()
    
    logger.info(f"Request started",
               extra={
                   'request_id': g.request_id,
                   'method': request.method,
                   'path': request.path,
                   'remote_addr': request.remote_addr
               })

@app.after_request
def after_request(response):
    response.headers['X-Content-Type-Options'] = 'nosniff'
    response.headers['X-Frame-Options'] = 'DENY'
    response.headers['X-XSS-Protection'] = '1; mode=block'
    response.headers['X-Request-ID'] = g.get('request_id', '')
    
    if response.status_code == 200:
        response.headers['Cache-Control'] = 'public, max-age=300'
    
    duration = time.time() - g.get('start_time', time.time())
    logger.info(f"Request completed",
               extra={
                   'request_id': g.get('request_id'),
                   'status_code': response.status_code,
                   'duration': round(duration * 1000, 2),
                   'method': request.method,
                   'path': request.path
               })
    
    return response

@app.errorhandler(HTTPException)
def handle_http_exception(e):
    return create_error_response(e.code, e.description)

@app.errorhandler(Exception)
def handle_exception(e):
    logger.error(f"Unhandled exception",
                extra={'request_id': g.get('request_id'), 'error': str(e)},
                exc_info=True)
    
    if app.config['DEBUG']:
        raise e
    
    return create_error_response(500, "An unexpected error occurred")

def create_response(data: Dict[str, Any], status_code: int = 200) -> Tuple[Dict[str, Any], int]:
    response = {
        'success': 200 <= status_code < 300,
        'data': data if 200 <= status_code < 300 else None,
        'error': data if status_code >= 400 else None,
        'timestamp': datetime.utcnow().isoformat(),
        'request_id': g.get('request_id')
    }
    return jsonify(response), status_code

def create_error_response(status_code: int, message: str, details: Optional[Dict] = None) -> Tuple[Dict[str, Any], int]:
    error_data = {
        'message': message,
        'code': status_code
    }
    if details:
        error_data['details'] = details
    
    return create_response(error_data, status_code)

def validate_city_input(city: str) -> str:
    if not city or not isinstance(city, str):
        raise ValueError("City name is required")
    
    city = city.strip()[:100]
    
    if not all(c.isalnum() or c in " -,.'()" for c in city):
        raise ValueError("Invalid characters in city name")
    
    return city

def validate_coordinates(lat: str, lon: str) -> Tuple[float, float]:
    try:
        lat_float = float(lat)
        lon_float = float(lon)
        
        if not (-90 <= lat_float <= 90):
            raise ValueError("Latitude must be between -90 and 90")
        
        if not (-180 <= lon_float <= 180):
            raise ValueError("Longitude must be between -180 and 180")
        
        return lat_float, lon_float
    except (TypeError, ValueError) as e:
        raise ValueError(f"Invalid coordinates: {str(e)}")

def make_weather_api_request(endpoint: str, params: Dict[str, Any]) -> Dict[str, Any]:
    url = f"{Config.WEATHER_API_BASE_URL}/{endpoint}"
    params['appid'] = Config.WEATHER_API_KEY
    params['units'] = 'metric'
    
    try:
        response = requests.get(
            url,
            params=params,
            timeout=Config.WEATHER_API_TIMEOUT,
            headers={'User-Agent': 'WeatherApp/1.0'}
        )
        
        if response.status_code == 404:
            raise ValueError("Location not found")
        
        response.raise_for_status()
        return response.json()
        
    except requests.exceptions.Timeout:
        logger.error(f"Weather API timeout", extra={'url': url})
        raise Exception("Weather service is temporarily unavailable")
    except requests.exceptions.RequestException as e:
        logger.error(f"Weather API error", extra={'url': url, 'error': str(e)})
        raise Exception("Unable to fetch weather data")

def transform_weather_data(data: Dict[str, Any]) -> Dict[str, Any]:
    return {
        'city': data['name'],
        'country': data['sys']['country'],
        'coordinates': {
            'latitude': data['coord']['lat'],
            'longitude': data['coord']['lon']
        },
        'temperature': {
            'current': round(data['main']['temp']),
            'feels_like': round(data['main']['feels_like']),
            'min': round(data['main']['temp_min']),
            'max': round(data['main']['temp_max'])
        },
        'weather': {
            'main': data['weather'][0]['main'],
            'description': data['weather'][0]['description'].title(),
            'icon': data['weather'][0]['icon']
        },
        'details': {
            'humidity': data['main']['humidity'],
            'pressure': data['main']['pressure'],
            'visibility': data.get('visibility', 10000) // 1000,
            'wind_speed': data['wind']['speed'],
            'wind_direction': data['wind'].get('deg', 0),
            'clouds': data['clouds']['all']
        },
        'sun': {
            'sunrise': datetime.fromtimestamp(data['sys']['sunrise']).strftime('%H:%M'),
            'sunset': datetime.fromtimestamp(data['sys']['sunset']).strftime('%H:%M')
        },
        'timezone': data.get('timezone', 0),
        'updated_at': datetime.fromtimestamp(data['dt']).isoformat()
    }

def transform_forecast_data(data: Dict[str, Any]) -> list:
    daily_forecasts = []
    processed_dates = set()
    
    for item in data['list']:
        date = datetime.fromtimestamp(item['dt']).date()
        if date not in processed_dates and len(daily_forecasts) < 5:
            daily_forecasts.append({
                'date': datetime.fromtimestamp(item['dt']).strftime('%Y-%m-%d'),
                'day': datetime.fromtimestamp(item['dt']).strftime('%A'),
                'temperature': {
                    'min': round(item['main']['temp_min']),
                    'max': round(item['main']['temp_max']),
                    'average': round(item['main']['temp'])
                },
                'weather': {
                    'main': item['weather'][0]['main'],
                    'description': item['weather'][0]['description'].title(),
                    'icon': item['weather'][0]['icon']
                },
                'details': {
                    'humidity': item['main']['humidity'],
                    'wind_speed': item['wind']['speed'],
                    'clouds': item['clouds']['all'],
                    'rain': item.get('rain', {}).get('3h', 0),
                    'snow': item.get('snow', {}).get('3h', 0)
                }
            })
            processed_dates.add(date)
    
    return daily_forecasts

def cache_response(timeout=300):
    def decorator(f):
        @wraps(f)
        def wrapped(*args, **kwargs):
            if app.config['DEBUG']:
                return f(*args, **kwargs)
            
            cache_key = f"{f.__name__}:{request.path}:{request.query_string.decode()}"
            
            cached = cache.get(cache_key)
            if cached:
                logger.info(f"Cache hit", extra={'cache_key': cache_key})
                return cached
            
            result = f(*args, **kwargs)
            
            if result[1] == 200:
                cache.set(cache_key, result, timeout=timeout)
            
            return result
        return wrapped
    return decorator

@app.route('/')
def index():
    return jsonify({
        'service': 'Weather API',
        'version': '1.0.0',
        'endpoints': {
            'health': '/health',
            'weather': '/api/v1/weather/{city}',
            'weather_by_coords': '/api/v1/weather/coordinates?lat={lat}&lon={lon}',
            'forecast': '/api/v1/forecast/{city}',
            'bulk_weather': '/api/v1/weather/bulk'
        }
    })

@app.route('/health', methods=['GET'])
@limiter.exempt
def health_check():
    health_status = {
        'status': 'healthy',
        'service': 'weather-api',
        'version': '1.0.0',
        'timestamp': datetime.utcnow().isoformat()
    }
    
    try:
        test_response = requests.get(
            f"{Config.WEATHER_API_BASE_URL}/weather",
            params={'q': 'London', 'appid': Config.WEATHER_API_KEY},
            timeout=5
        )
        health_status['weather_api'] = 'available' if test_response.status_code == 200 else 'unavailable'
    except:
        health_status['weather_api'] = 'unavailable'
        health_status['status'] = 'degraded'
    
    status_code = 200 if health_status['status'] == 'healthy' else 503
    return jsonify(health_status), status_code

@app.route('/api/v1/weather/<city>', methods=['GET'])
@limiter.limit("30 per minute")
@cache_response(timeout=300)
def get_weather(city):
    try:
        city = validate_city_input(city)
        weather_data = make_weather_api_request('weather', {'q': city})
        transformed_data = transform_weather_data(weather_data)
        return create_response(transformed_data)
        
    except ValueError as e:
        return create_error_response(400, str(e))
    except Exception as e:
        logger.error(f"Error fetching weather", 
                    extra={'city': city, 'error': str(e), 'request_id': g.get('request_id')})
        return create_error_response(500, str(e))

@app.route('/api/v1/weather/coordinates', methods=['GET'])
@limiter.limit("30 per minute")
@cache_response(timeout=300)
def get_weather_by_coordinates():
    try:
        lat = request.args.get('lat')
        lon = request.args.get('lon')
        
        if not lat or not lon:
            return create_error_response(400, "Latitude and longitude are required")
        
        lat, lon = validate_coordinates(lat, lon)
        weather_data = make_weather_api_request('weather', {'lat': lat, 'lon': lon})
        transformed_data = transform_weather_data(weather_data)
        
        return create_response(transformed_data)
        
    except ValueError as e:
        return create_error_response(400, str(e))
    except Exception as e:
        logger.error(f"Error fetching weather by coordinates", 
                    extra={'lat': lat, 'lon': lon, 'error': str(e), 'request_id': g.get('request_id')})
        return create_error_response(500, str(e))

@app.route('/api/v1/forecast/<city>', methods=['GET'])
@limiter.limit("20 per minute")
@cache_response(timeout=600)
def get_forecast(city):
    try:
        city = validate_city_input(city)
        forecast_data = make_weather_api_request('forecast', {'q': city, 'cnt': 40})
        transformed_data = transform_forecast_data(forecast_data)
        
        return create_response({
            'city': forecast_data['city']['name'],
            'country': forecast_data['city']['country'],
            'forecast': transformed_data
        })
        
    except ValueError as e:
        return create_error_response(400, str(e))
    except Exception as e:
        logger.error(f"Error fetching forecast", 
                    extra={'city': city, 'error': str(e), 'request_id': g.get('request_id')})
        return create_error_response(500, str(e))

@app.route('/api/v1/weather/bulk', methods=['POST'])
@limiter.limit("10 per minute")
def get_bulk_weather():
    try:
        if not request.is_json:
            return create_error_response(400, "Content-Type must be application/json")
        
        data = request.get_json()
        cities = data.get('cities', [])
        
        if not cities or not isinstance(cities, list):
            return create_error_response(400, "Cities array is required")
        
        if len(cities) > 10:
            return create_error_response(400, "Maximum 10 cities allowed per request")
        
        results = []
        errors = []
        
        for city in cities:
            try:
                city = validate_city_input(city)
                weather_data = make_weather_api_request('weather', {'q': city})
                results.append(transform_weather_data(weather_data))
            except Exception as e:
                errors.append({
                    'city': city,
                    'error': str(e)
                })
        
        response_data = {
            'results': results,
            'errors': errors,
            'success_count': len(results),
            'error_count': len(errors)
        }
        
        return create_response(response_data)
        
    except Exception as e:
        logger.error(f"Error in bulk weather request", 
                    extra={'error': str(e), 'request_id': g.get('request_id')})
        return create_error_response(500, str(e))

def shutdown_handler(signum, frame):
    logger.info("Received shutdown signal, cleaning up...")
    sys.exit(0)

import signal
signal.signal(signal.SIGTERM, shutdown_handler)
signal.signal(signal.SIGINT, shutdown_handler)

if __name__ == '__main__':
    port = int(os.environ.get('PORT', 5000))
    
    if app.config['ENV'] == 'production':
        logger.warning("Running with Flask development server. Use gunicorn for production!")
    
    app.run(
        host='0.0.0.0',
        port=port,
        debug=app.config['DEBUG']
    )