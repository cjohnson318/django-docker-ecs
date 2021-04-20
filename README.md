# Django in Docker on ECS

## Environment

I like to use `direnv` and `pyenv` to control my environment.

```bash
$ touch .env.local
$ touch .envrc
$ touch .gitignore
```

Add the following to `.envrc`.

```
use pyenv 3.9.1
dotenv ".env.local"
```

Then allow `direnv` to set up the environment.

```bash
direnv allow
```

Add the following to `.gitignore`

```
.direnv
.env.local
```

Create a `src` directory where your application source code will live.

```bash
mkdir src
```

Now, you should have a local virtual enviornment set up.

```bash
pip install django
```

Start a requirements file for your application.

```bash
pip freeze > src/requirements.txt
```


## Django

Use pip to install a dependency to use dot-files.

```bash
pip install python-dotenv
pip freeze > src/requirements.txt
```

Navigate to the `src` directory, and start building a Django application.

```bash
cd src
django-admin startproject config .
```

Add the following to `.env.local`.

```
ENVIRONMENT=LOCAL

DJANGO_ALLOWED_HOSTS=localhost
DJANGO_SECRET_KEY='<replace-this-with-SECRET-KEY>'
DJANGO_DB_ENGINE=django.db.backends.postgresql

POSTGRES_PASSWORD='<replace-with-some-password>'
POSTGRES_USER=postgres
POSTGRES_HOSTNAME=db
POSTGRES_PORT=5432
POSTGRES_DB=db
POSTGRES_HOST_AUTH_METHOD=trust
```

Next, configure `config/settings.py`. We'll tackle the following,

  1. Imports, importing `os` and `dotenv`
  2. Security Key, copy the original to `.env.local`
  3. Debug, set True locally, but False elswhere
  4. Allowed Hosts, set to `localhost` locally
  5. Edit the database settings

First, we import `os` and `dotenv` and then configure `dotenv`.

```python
import os
from pathlib import Path

from dotenv import load_dotenv
load_dotenv()
```

Then copy the existing `SECRET_KEY` to the `.env.local`, and refrence it using
`os.getenv`. Add an if-else structure around `DEBUG`. Reference the
`ALLOWED_HOSTS` variable.

```python
# SECURITY WARNING: keep the secret key used in production secret!
SECRET_KEY = os.getenv('DJANGO_SECRET_KEY')

# SECURITY WARNING: don't run with debug turned on in production!
if os.getenv('ENVIRONMENT') == 'LOCAL':
    DEBUG = True
else:
    DEBUG = False

ALLOWED_HOSTS = [
    os.getenv('DJANGO_ALLOWED_HOSTS')
]
```

Finally, replace the `DATABASE` variable in `config/settings.py` with,

```python
DATABASES = {
    'default': {
        'ENGINE':   os.getenv('DJANGO_DB_ENGINE'),
        'NAME':     os.getenv('POSTGRES_DB'),
        'USER':     os.getenv('POSTGRES_USER'),
        'PASSWORD': os.getenv('POSTGRES_PASSWORD'),
        'HOST':     os.getenv('POSTGRES_HOSTNAME'),
        'PORT':     os.getenv('POSTGRES_PORT'),
    }
}
```

At this point, you might create an app using `django-admin startapp <app>`. If
you do that, then you can follow any number of Django guides on the internet.
This is guide provides a bare-minimum and won't (yet) gett into building apps.


## Docker

From the command line, **outside** of the `src/` directory,

```bash
touch Dockerfile
touch docker-compose.yml
```

Open `Dockerfile` and add the following,

```
# Pull base image
FROM python:3.9.1

# Set environment variables
ENV PYTHONDONTWRITEBYTECODE=1
ENV PYTHONUNBUFFERED=1

# Set working directory
WORKDIR /usr/src/app

# Copy project
COPY src /usr/src/app

# Install dependencies
RUN pip install -r /usr/src/app/requirements.txt

# Expose port 8000
EXPOSE 8000

# Start the web server
CMD python manage.py runserver 0.0.0.0:8000
```

Open `docker-compose.yml` and add the following,

```
version: '3.8'
services:
  app:
    build:
      context: ./
      dockerfile: Dockerfile
    depends_on:
      - db
    env_file:
      - .env.local
    ports:
      - 8000:8000
    volumes:
      - ./src:/usr/src/app
  db:
    image: postgres:11
    ports:
      - 5432:5432
    volumes:
      - postgres_data:/var/lib/postgresql/data/
    env_file:
      - .env.local

volumes:
  postgres_data:
```

You should now be able to build an image by running,

```bash
docker-compose build
```

And then you should be able to bring the server up by running,

```bash
docker-compose up
```

If you go to `localhost:8000` in a browser, you should see a landiing page with
a rocket.
