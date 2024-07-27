install:
	cd frontend && npm install
	cd backend && mvn install

docs: 	
	cd docs && make

run: install
	cd backend && nohup bash ./run.sh >/dev/null 2>&1 &
	cd frontend && nohup npm run dev >/dev/null 2>&1 &
	open http://localhost:3000
