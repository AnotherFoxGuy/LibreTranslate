# first stage
FROM python:3.8 AS builder
COPY requirements.txt .

# install dependencies to the local user directory (eg. /root/.local)
RUN pip install --user -r requirements.txt

# second unnamed stage
FROM python:3.8
WORKDIR /app

ARG with_models=false

# copy only the dependencies installation from the 1st stage image
COPY --from=builder /root/.local /root/.local
COPY . .

# check for offline build
RUN if [ "$with_models" = "true" ]; then  \
        # initialize the language models
        ./install_models.py;  \
    fi

# update PATH environment variable
ENV PATH=/root/.local:/root/.local/bin:$PATH

#EXPOSE 5000 
#CMD python main.py --host 0.0.0.0 --host $PORT
CMD gunicorn --bind 0.0.0.0:$PORT 'wsgi:app'