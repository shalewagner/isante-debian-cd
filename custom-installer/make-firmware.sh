#!/bin/bash

pax -x sv4cpio -w /lib/firmware | gzip -c > firmware.cpio.gz
