FROM python:3.12-slim

WORKDIR /app

# Only runtime dependency for console proxy mode.
RUN pip install --no-cache-dir cryptography==46.0.5

COPY proxy ./proxy

EXPOSE 1080

CMD ["sh", "-c", "python proxy/tg_ws_proxy.py --host 0.0.0.0 --port ${PORT:-1080} --dc-ip ${DC_IP_1:-2:149.154.167.220} --dc-ip ${DC_IP_2:-4:149.154.167.220} ${VERBOSE:+-v}"]
