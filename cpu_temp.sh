#!/bin/sh

        sensors -f | grep "Package id 0:" | tr -d '+' | awk '{print $4}'
