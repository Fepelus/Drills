
build: web/index.html web/main.dart web/styles.css
	pub build

upload: build/web/main.dart.js 
	cd build/web; scp -r * fepelus1@fepelus.com:public_html/drills
