#!/usr/bin/env sh

curl http://local.m.apartmentguide.com/apartments/Georgia/Atlanta/10-miles/ | egrep "canonical\' href=.*10-miles/"
