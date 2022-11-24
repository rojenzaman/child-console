default:
	@true

check: INSTALL cpanfile
	@echo Checking requirements...
	@local/bin/check.sh
