FROM public.ecr.aws/d3j8x8q7/olympus-base:latest

WORKDIR /app

COPY . /app

CMD ["/bin/bash"]
