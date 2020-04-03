#!/usr/bin/env python

import sys
import threading
import requests, urllib3
from datetime import datetime

class Cl:
	end	= '\033[0m'
	grn	= '\033[01;32m'
	mgn	= '\033[01;35m'
	ble = '\033[01;34m'
	brd = '\033[01;91m'
	ylw	= '\033[01;33m'
	red	= '\033[01;31m'
	wht	= '\033[01;37m'

def check_shell(url):
	if url[:4] != "http":
		url = "http://{}".format(url)

	try:
		req	= session.get(url, headers=head, verify=False, timeout=10)
		res = req.url.lower().replace("%0d", "").replace("%0a", "")

		if req.status_code == 000 and res == url.replace("\r", ""):
			s_000.write(url+"\n")
			s_000.flush()
			print("{}[{}{}{}][{}{}{}] {}{}{}".format(Cl.wht, Cl.red, req.status_code, Cl.wht, Cl.red, datetime.now().strftime('%H:%M:%S'), Cl.wht, Cl.red, url, Cl.end).strip())

		elif req.status_code == 101 and res == url.replace("\r", ""):
			s_101.write(url+"\n")
			s_101.flush()
			print("{}[{}{}{}][{}{}{}] {}{}{}".format(Cl.wht, Cl.brd, req.status_code, Cl.wht, Cl.brd, datetime.now().strftime('%H:%M:%S'), Cl.wht, Cl.brd, url, Cl.end).strip())

		elif req.status_code == 102 and res == url.replace("\r", ""):
			s_102.write(url+"\n")
			s_102.flush()
			print("{}[{}{}{}][{}{}{}] {}{}{}".format(Cl.wht, Cl.brd, req.status_code, Cl.wht, Cl.brd, datetime.now().strftime('%H:%M:%S'), Cl.wht, Cl.brd, url, Cl.end).strip())

		elif req.status_code == 200 and res == url.replace("\r", ""):
			s_200.write(url+"\n")
			s_200.flush()
			print("{}[{}{}{}][{}{}{}] {}{}{}".format(Cl.wht, Cl.grn, req.status_code, Cl.wht, Cl.grn, datetime.now().strftime('%H:%M:%S'), Cl.wht, Cl.grn, url, Cl.end).strip())

		elif req.status_code == 201 and res == url.replace("\r", ""):
			s_201.write(url+"\n")
			s_201.flush()
			print("{}[{}{}{}][{}{}{}] {}{}{}".format(Cl.wht, Cl.mgn, req.status_code, Cl.wht, Cl.mgn, datetime.now().strftime('%H:%M:%S'), Cl.wht, Cl.mgn, url, Cl.end).strip())

		elif req.status_code == 202 and res == url.replace("\r", ""):
			s_202.write(url+"\n")
			s_202.flush()
			print("{}[{}{}{}][{}{}{}] {}{}{}".format(Cl.wht, Cl.mgn, req.status_code, Cl.wht, Cl.mgn, datetime.now().strftime('%H:%M:%S'), Cl.wht, Cl.mgn, url, Cl.end).strip())

		elif req.status_code == 203 and res == url.replace("\r", ""):
			s_203.write(url+"\n")
			s_203.flush()
			print("{}[{}{}{}][{}{}{}] {}{}{}".format(Cl.wht, Cl.mgn, req.status_code, Cl.wht, Cl.mgn, datetime.now().strftime('%H:%M:%S'), Cl.wht, Cl.mgn, url, Cl.end).strip())

		elif req.status_code == 204 and res == url.replace("\r", ""):
			s_204.write(url+"\n")
			s_204.flush()
			print("{}[{}{}{}][{}{}{}] {}{}{}".format(Cl.wht, Cl.mgn, req.status_code, Cl.wht, Cl.mgn, datetime.now().strftime('%H:%M:%S'), Cl.wht, Cl.mgn, url, Cl.end).strip())

		elif req.status_code == 205 and res == url.replace("\r", ""):
			s_205.write(url+"\n")
			s_205.flush()
			print("{}[{}{}{}][{}{}{}] {}{}{}".format(Cl.wht, Cl.mgn, req.status_code, Cl.wht, Cl.mgn, datetime.now().strftime('%H:%M:%S'), Cl.wht, Cl.mgn, url, Cl.end).strip())

		elif req.status_code == 206 and res == url.replace("\r", ""):
			s_206.write(url+"\n")
			s_206.flush()
			print("{}[{}{}{}][{}{}{}] {}{}{}".format(Cl.wht, Cl.mgn, req.status_code, Cl.wht, Cl.mgn, datetime.now().strftime('%H:%M:%S'), Cl.wht, Cl.mgn, url, Cl.end).strip())

		elif req.status_code == 300 and res == url.replace("\r", ""):
			s_300.write(url+"\n")
			s_300.flush()
			print("{}[{}{}{}][{}{}{}] {}{}{}".format(Cl.wht, Cl.ble, req.status_code, Cl.wht, Cl.ble, datetime.now().strftime('%H:%M:%S'), Cl.wht, Cl.ble, url, Cl.end).strip())

		elif req.status_code == 301 and res == url.replace("\r", ""):
			s_301.write(url+"\n")
			s_301.flush()
			print("{}[{}{}{}][{}{}{}] {}{}{}".format(Cl.wht, Cl.ble, req.status_code, Cl.wht, Cl.ble, datetime.now().strftime('%H:%M:%S'), Cl.wht, Cl.ble, url, Cl.end).strip())

		elif req.status_code == 302 and res == url.replace("\r", ""):
			s_302.write(url+"\n")
			s_302.flush()
			print("{}[{}{}{}][{}{}{}] {}{}{}".format(Cl.wht, Cl.ble, req.status_code, Cl.wht, Cl.ble, datetime.now().strftime('%H:%M:%S'), Cl.wht, Cl.ble, url, Cl.end).strip())

		elif req.status_code == 303 and res == url.replace("\r", ""):
			s_303.write(url+"\n")
			s_303.flush()
			print("{}[{}{}{}][{}{}{}] {}{}{}".format(Cl.wht, Cl.ble, req.status_code, Cl.wht, Cl.ble, datetime.now().strftime('%H:%M:%S'), Cl.wht, Cl.ble, url, Cl.end).strip())

		elif req.status_code == 304 and res == url.replace("\r", ""):
			s_304.write(url+"\n")
			s_304.flush()
			print("{}[{}{}{}][{}{}{}] {}{}{}".format(Cl.wht, Cl.ble, req.status_code, Cl.wht, Cl.ble, datetime.now().strftime('%H:%M:%S'), Cl.wht, Cl.ble, url, Cl.end).strip())

		elif req.status_code == 305 and res == url.replace("\r", ""):
			s_305.write(url+"\n")
			s_305.flush()
			print("{}[{}{}{}][{}{}{}] {}{}{}".format(Cl.wht, Cl.ble, req.status_code, Cl.wht, Cl.ble, datetime.now().strftime('%H:%M:%S'), Cl.wht, Cl.ble, url, Cl.end).strip())

		elif req.status_code == 306 and res == url.replace("\r", ""):
			s_306.write(url+"\n")
			s_306.flush()
			print("{}[{}{}{}][{}{}{}] {}{}{}".format(Cl.wht, Cl.ble, req.status_code, Cl.wht, Cl.ble, datetime.now().strftime('%H:%M:%S'), Cl.wht, Cl.ble, url, Cl.end).strip())

		elif req.status_code == 307 and res == url.replace("\r", ""):
			s_307.write(url+"\n")
			s_307.flush()
			print("{}[{}{}{}][{}{}{}] {}{}{}".format(Cl.wht, Cl.ble, req.status_code, Cl.wht, Cl.ble, datetime.now().strftime('%H:%M:%S'), Cl.wht, Cl.ble, url, Cl.end).strip())

		elif req.status_code == 400 and res == url.replace("\r", ""):
			s_400.write(url+"\n")
			s_400.flush()
			print("{}[{}{}{}][{}{}{}] {}{}{}".format(Cl.wht, Cl.ylw, req.status_code, Cl.wht, Cl.ylw, datetime.now().strftime('%H:%M:%S'), Cl.wht, Cl.ylw, url, Cl.end).strip())

		elif req.status_code == 401 and res == url.replace("\r", ""):
			s_401.write(url+"\n")
			s_401.flush()
			print("{}[{}{}{}][{}{}{}] {}{}{}".format(Cl.wht, Cl.ylw, req.status_code, Cl.wht, Cl.ylw, datetime.now().strftime('%H:%M:%S'), Cl.wht, Cl.ylw, url, Cl.end).strip())

		elif req.status_code == 402 and res == url.replace("\r", ""):
			s_402.write(url+"\n")
			s_402.flush()
			print("{}[{}{}{}][{}{}{}] {}{}{}".format(Cl.wht, Cl.ylw, req.status_code, Cl.wht, Cl.ylw, datetime.now().strftime('%H:%M:%S'), Cl.wht, Cl.ylw, url, Cl.end).strip())

		elif req.status_code == 403 and res == url.replace("\r", ""):
			s_403.write(url+"\n")
			s_403.flush()
			print("{}[{}{}{}][{}{}{}] {}{}{}".format(Cl.wht, Cl.ylw, req.status_code, Cl.wht, Cl.ylw, datetime.now().strftime('%H:%M:%S'), Cl.wht, Cl.ylw, url, Cl.end).strip())

		elif req.status_code == 404 and res == url.replace("\r", ""):
			s_404.write(url+"\n")
			s_404.flush()
			print("{}[{}{}{}][{}{}{}] {}{}{}".format(Cl.wht, Cl.ylw, req.status_code, Cl.wht, Cl.ylw, datetime.now().strftime('%H:%M:%S'), Cl.wht, Cl.ylw, url, Cl.end).strip())

		elif req.status_code == 405 and res == url.replace("\r", ""):
			s_405.write(url+"\n")
			s_405.flush()
			print("{}[{}{}{}][{}{}{}] {}{}{}".format(Cl.wht, Cl.ylw, req.status_code, Cl.wht, Cl.ylw, datetime.now().strftime('%H:%M:%S'), Cl.wht, Cl.ylw, url, Cl.end).strip())

		elif req.status_code == 406 and res == url.replace("\r", ""):
			s_406.write(url+"\n")
			s_406.flush()
			print("{}[{}{}{}][{}{}{}] {}{}{}".format(Cl.wht, Cl.ylw, req.status_code, Cl.wht, Cl.ylw, datetime.now().strftime('%H:%M:%S'), Cl.wht, Cl.ylw, url, Cl.end).strip())

		elif req.status_code == 407 and res == url.replace("\r", ""):
			s_407.write(url+"\n")
			s_407.flush()
			print("{}[{}{}{}][{}{}{}] {}{}{}".format(Cl.wht, Cl.ylw, req.status_code, Cl.wht, Cl.ylw, datetime.now().strftime('%H:%M:%S'), Cl.wht, Cl.ylw, url, Cl.end).strip())

		elif req.status_code == 408 and res == url.replace("\r", ""):
			s_408.write(url+"\n")
			s_408.flush()
			print("{}[{}{}{}][{}{}{}] {}{}{}".format(Cl.wht, Cl.ylw, req.status_code, Cl.wht, Cl.ylw, datetime.now().strftime('%H:%M:%S'), Cl.wht, Cl.ylw, url, Cl.end).strip())

		elif req.status_code == 409 and res == url.replace("\r", ""):
			s_409.write(url+"\n")
			s_409.flush()
			print("{}[{}{}{}][{}{}{}] {}{}{}".format(Cl.wht, Cl.ylw, req.status_code, Cl.wht, Cl.ylw, datetime.now().strftime('%H:%M:%S'), Cl.wht, Cl.ylw, url, Cl.end).strip())

		elif req.status_code == 410 and res == url.replace("\r", ""):
			s_410.write(url+"\n")
			s_410.flush()
			print("{}[{}{}{}][{}{}{}] {}{}{}".format(Cl.wht, Cl.ylw, req.status_code, Cl.wht, Cl.ylw, datetime.now().strftime('%H:%M:%S'), Cl.wht, Cl.ylw, url, Cl.end).strip())

		elif req.status_code == 411 and res == url.replace("\r", ""):
			s_411.write(url+"\n")
			s_411.flush()
			print("{}[{}{}{}][{}{}{}] {}{}{}".format(Cl.wht, Cl.ylw, req.status_code, Cl.wht, Cl.ylw, datetime.now().strftime('%H:%M:%S'), Cl.wht, Cl.ylw, url, Cl.end).strip())

		elif req.status_code == 412 and res == url.replace("\r", ""):
			s_412.write(url+"\n")
			s_412.flush()
			print("{}[{}{}{}][{}{}{}] {}{}{}".format(Cl.wht, Cl.ylw, req.status_code, Cl.wht, Cl.ylw, datetime.now().strftime('%H:%M:%S'), Cl.wht, Cl.ylw, url, Cl.end).strip())

		elif req.status_code == 413 and res == url.replace("\r", ""):
			s_413.write(url+"\n")
			s_413.flush()
			print("{}[{}{}{}][{}{}{}] {}{}{}".format(Cl.wht, Cl.ylw, req.status_code, Cl.wht, Cl.ylw, datetime.now().strftime('%H:%M:%S'), Cl.wht, Cl.ylw, url, Cl.end).strip())

		elif req.status_code == 414 and res == url.replace("\r", ""):
			s_414.write(url+"\n")
			s_414.flush()
			print("{}[{}{}{}][{}{}{}] {}{}{}".format(Cl.wht, Cl.ylw, req.status_code, Cl.wht, Cl.ylw, datetime.now().strftime('%H:%M:%S'), Cl.wht, Cl.ylw, url, Cl.end).strip())

		elif req.status_code == 415 and res == url.replace("\r", ""):
			s_415.write(url+"\n")
			s_415.flush()
			print("{}[{}{}{}][{}{}{}] {}{}{}".format(Cl.wht, Cl.ylw, req.status_code, Cl.wht, Cl.ylw, datetime.now().strftime('%H:%M:%S'), Cl.wht, Cl.ylw, url, Cl.end).strip())

		elif req.status_code == 416 and res == url.replace("\r", ""):
			s_416.write(url+"\n")
			s_416.flush()
			print("{}[{}{}{}][{}{}{}] {}{}{}".format(Cl.wht, Cl.ylw, req.status_code, Cl.wht, Cl.ylw, datetime.now().strftime('%H:%M:%S'), Cl.wht, Cl.ylw, url, Cl.end).strip())

		elif req.status_code == 417 and res == url.replace("\r", ""):
			s_417.write(url+"\n")
			s_417.flush()
			print("{}[{}{}{}][{}{}{}] {}{}{}".format(Cl.wht, Cl.ylw, req.status_code, Cl.wht, Cl.ylw, datetime.now().strftime('%H:%M:%S'), Cl.wht, Cl.ylw, url, Cl.end).strip())

		elif req.status_code == 500 and res == url.replace("\r", ""):
			s_500.write(url+"\n")
			s_500.flush()
			print("{}[{}{}{}][{}{}{}] {}{}{}".format(Cl.wht, Cl.red, req.status_code, Cl.wht, Cl.red, datetime.now().strftime('%H:%M:%S'), Cl.wht, Cl.red, url, Cl.end).strip())

		elif req.status_code == 501 and res == url.replace("\r", ""):
			s_501.write(url+"\n")
			s_501.flush()
			print("{}[{}{}{}][{}{}{}] {}{}{}".format(Cl.wht, Cl.red, req.status_code, Cl.wht, Cl.red, datetime.now().strftime('%H:%M:%S'), Cl.wht, Cl.red, url, Cl.end).strip())

		elif req.status_code == 502 and res == url.replace("\r", ""):
			s_502.write(url+"\n")
			s_502.flush()
			print("{}[{}{}{}][{}{}{}] {}{}{}".format(Cl.wht, Cl.red, req.status_code, Cl.wht, Cl.red, datetime.now().strftime('%H:%M:%S'), Cl.wht, Cl.red, url, Cl.end).strip())

		elif req.status_code == 503 and res == url.replace("\r", ""):
			s_503.write(url+"\n")
			s_503.flush()
			print("{}[{}{}{}][{}{}{}] {}{}{}".format(Cl.wht, Cl.red, req.status_code, Cl.wht, Cl.red, datetime.now().strftime('%H:%M:%S'), Cl.wht, Cl.red, url, Cl.end).strip())

		elif req.status_code == 504 and res == url.replace("\r", ""):
			s_504.write(url+"\n")
			s_504.flush()
			print("{}[{}{}{}][{}{}{}] {}{}{}".format(Cl.wht, Cl.red, req.status_code, Cl.wht, Cl.red, datetime.now().strftime('%H:%M:%S'), Cl.wht, Cl.red, url, Cl.end).strip())

		elif req.status_code == 505 and res == url.replace("\r", ""):
			s_505.write(url+"\n")
			s_505.flush()
			print("{}[{}{}{}][{}{}{}] {}{}{}".format(Cl.wht, Cl.red, req.status_code, Cl.wht, Cl.red, datetime.now().strftime('%H:%M:%S'), Cl.wht, Cl.red, url, Cl.end).strip())
		else:
			pass

	except requests.exceptions.ConnectionError:
		pass
	except requests.exceptions.Timeout:
		pass
	except KeyboardInterrupt:
		print("\n[!] Close Scanning ...")
		s_000.close()
		s_100.close()
		s_101.close()
		s_200.close()
		s_201.close()
		s_202.close()
		s_203.close()
		s_204.close()
		s_205.close()
		s_206.close()
		s_300.close()
		s_301.close()
		s_302.close()
		s_303.close()
		s_304.close()
		s_305.close()
		s_306.close()
		s_307.close()
		s_400.close()
		s_401.close()
		s_402.close()
		s_403.close()
		s_404.close()
		s_405.close()
		s_406.close()
		s_407.close()
		s_408.close()
		s_409.close()
		s_410.close()
		s_411.close()
		s_412.close()
		s_413.close()
		s_414.close()
		s_415.close()
		s_416.close()
		s_417.close()
		s_500.close()
		s_501.close()
		s_502.close()
		s_503.close()
		s_504.close()
		s_505.close()
		exit(0)
	except Exception as e:
		print("[!][Error] {}".format(e))

	return True

def main():
	global head, session
	global s_000, s_100, s_101, s_200, s_201, s_202, s_203, s_204, s_205, s_206, s_300, s_301, s_302, s_303, s_304, s_305, s_306, s_307, s_400, s_401, s_402, s_403, s_404, s_405, s_406, s_407, s_408, s_409, s_410, s_411, s_412, s_413, s_414, s_415, s_416, s_417, s_500, s_501, s_502, s_503, s_504, s_505

	urllib3.disable_warnings(urllib3.exceptions.InsecureRequestWarning)
	s_000 = open("000-not-responding.log", "w")
	s_100 = open("100-informational-continue.log", "w")
	s_101 = open("101-informational-protocols.log", "w")
	s_200 = open("200-successful-exist.log", "w")
	s_201 = open("201-successful-created.log", "w")
	s_202 = open("202-successful-accepted.log", "w")
	s_203 = open("203-successful-non-authoritative.log", "w")
	s_204 = open("204-successful-no-content.log", "w")
	s_205 = open("205-successful-reset-content.log", "w")
	s_206 = open("206-successful-partial-content.log", "w")
	s_300 = open("300-redirection-multiple-choices.log", "w")
	s_301 = open("301-redirection-moved-permanently.log", "w")
	s_302 = open("302-redirection-temporarily-different.log", "w")
	s_303 = open("303-redirection-see-other.log", "w")
	s_304 = open("304-redirection-not-modified.log", "w")
	s_305 = open("305-redirection-use-proxy.log", "w")
	s_306 = open("306-redirection-status-not-defined.log", "w")
	s_307 = open("307-redirection-temporary-redirect.log", "w")
	s_400 = open("400-client-error-bad-request.log", "w")
	s_401 = open("401-client-error-unauthorized.log", "w")
	s_402 = open("402-client-error-payment-required.log", "w")
	s_403 = open("403-client-error-forbidden.log", "w")
	s_404 = open("404-client-error-not-found.log", "w")
	s_405 = open("405-client-error-method-not-allowed.log", "w")
	s_406 = open("406-client-error-not-acceptable.log", "w")
	s_407 = open("407-client-error-proxy-authentication.log", "w")
	s_408 = open("408-client-error-request-timeout.log", "w")
	s_409 = open("409-client-error-conflict.log", "w")
	s_410 = open("410-client-error-gone.log", "w")
	s_411 = open("411-client-error-length-required.log", "w")
	s_412 = open("412-client-error-precondition-failed.log", "w")
	s_413 = open("413-client-error-entity-too-large.log", "w")
	s_414 = open("414-client-error-uri-too-long.log", "w")
	s_415 = open("415-client-error-unsupported-media-type.log", "w")
	s_416 = open("416-client-error-requested-not-satisfiable.log", "w")
	s_417 = open("417-client-error-expectation-failed.log", "w")
	s_500 = open("500-server-error-internal-server-error.log", "w")
	s_501 = open("501-server-error-not-implemented.log", "w")
	s_502 = open("502-server-error-bad-gateway.log", "w")
	s_503 = open("503-server-error-service-unavailable.log", "w")
	s_504 = open("504-server-error-gateway-timeout.log", "w")
	s_505 = open("505-server-error-version-not-supported.log", "w")
	session	= requests.Session()
	head = {
		"User-Agent" : "Mozilla/5.0 (Windows NT 10.0; Win64; x64; rv:67.0) Gecko/20100101 Firefox/67.0",
		"Connection" : "Keep-Alive"
	}

	try :
		target	= [i for i in open(sys.argv[1]).read().split("\n") if i != ""]
	except IOError:
		print("[!][Error] No such file or directory: '{}'".format(sys.argv[1]))
	except:
		print("[+] Usage: checkurls list.txt")
		exit(0)

	for i in target:
		try:
			t = threading.Thread(target=check_shell, args=(i,))
			t.start()
		except KeyboardInterrupt:
			print("\n[!] Close Scanning ...")
			s_000.close()
			s_100.close()
			s_101.close()
			s_200.close()
			s_201.close()
			s_202.close()
			s_203.close()
			s_204.close()
			s_205.close()
			s_206.close()
			s_300.close()
			s_301.close()
			s_302.close()
			s_303.close()
			s_304.close()
			s_305.close()
			s_306.close()
			s_307.close()
			s_400.close()
			s_401.close()
			s_402.close()
			s_403.close()
			s_404.close()
			s_405.close()
			s_406.close()
			s_407.close()
			s_408.close()
			s_409.close()
			s_410.close()
			s_411.close()
			s_412.close()
			s_413.close()
			s_414.close()
			s_415.close()
			s_416.close()
			s_417.close()
			s_500.close()
			s_501.close()
			s_502.close()
			s_503.close()
			s_504.close()
			s_505.close()
			exit(0)
		except Exception as e:
			print("[!][Error] {}".format(e))

	return True

if __name__ == "__main__":
	try:
		main()
	except KeyboardInterrupt:
		print("\n[!] Close Scanning...")
		s_000.close()
		s_100.close()
		s_101.close()
		s_200.close()
		s_201.close()
		s_202.close()
		s_203.close()
		s_204.close()
		s_205.close()
		s_206.close()
		s_300.close()
		s_301.close()
		s_302.close()
		s_303.close()
		s_304.close()
		s_305.close()
		s_306.close()
		s_307.close()
		s_400.close()
		s_401.close()
		s_402.close()
		s_403.close()
		s_404.close()
		s_405.close()
		s_406.close()
		s_407.close()
		s_408.close()
		s_409.close()
		s_410.close()
		s_411.close()
		s_412.close()
		s_413.close()
		s_414.close()
		s_415.close()
		s_416.close()
		s_417.close()
		s_500.close()
		s_501.close()
		s_502.close()
		s_503.close()
		s_504.close()
		s_505.close()
		exit(0)
	except Exception as e:
		print("[!][Error] {}".format(e))
