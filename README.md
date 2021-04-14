# Django in Docker on ECS

## Environment

I like to use `direnv` and `pyenv` to control my environment.

```
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

```
$ direnv allow
```

Add the following to `.gitignore`

```
.direnv
.env.local
```

Create a `src` directory where your application source code will live.

```
$ mkdir src
```

Now, you should have a local virtual enviornment set up.

```
pip install django
```

Start a requirements file for your application.

```
pip freeze > src/requirements.txt
```

