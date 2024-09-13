# dump1090
 Alpine based docker image of dump1090 with nginx web server.
 Small image size: 21.1 MB.
 This image can be used as a local receive and display of ADSB data.
 piaware is not included so the container doesn't talk to flightaware.com.

## Includes
 -  dump1090 to read an RTLSDR receive
 -  nginx web-server to serve up pages at http://localhost:8080
## Generally, I run this with a docker compose yml file:
```
name: dump1090
services:
  dump1090:
    container_name: dump1090
    image: dump1090:alpine
    restart: unless-stopped
    init: true
    ports: 
        - 8080:8080
    devices:
      - /dev/bus/usb
    environment:
      RECEIVER_LON: "-106.51992"
      RECEIVER_LAT: "35.05850"
      RECEIVER: "rtlsdr"
      RECEIVER_SERIAL: "00001090"
      JSON_LOCATION_ACCURACY: 2
```
