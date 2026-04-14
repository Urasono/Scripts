#!/usr/bin/bash

check_sensors() {

  sensors-detect || true
}

detect_sensors() {

  sensors || true
}

main() {

  check_sensors
  detect_sensors
}
