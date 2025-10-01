# install

1) установить [Nvidia CUDA Toolkit](https://developer.nvidia.com/cuda-downloads)
2) проверить что выполняется команда ``nvidia-smi`` и выводит данные о видюхе.
3) Если запускаете из windows, то запустить WSL, установить nvidia cuda ещё и в нём.
4) docker desktop - проверить переключить его на WSL версию с установелнной версией CUDA.
5) 

# build go
```
#Linux:
set GOOS=linux
$env:GOOS="linux"
set GOARCH=amd64
$env:GOARCH="amd64"
go build -o transcribe main.go

#Windows:
$env:GOOS="windows"
$env:GOARCH="amd64"
go build -o transcribe.exe main.go
go build -o C:\Dev\meetRunner\transcribe.exe main.go
```


# build docker

```
docker build -t timsof/whisper.cpp:latest .
docker tag timsof/whisper.cpp:latest timsof/whisper.cpp.cuda:latest
docker tag timsof/whisper.cpp:latest timsof/whisper.cpp.cuda:1.0.0
docker login
docker push timsof/whisper.cpp.cuda:latest
docker push timsof/whisper.cpp.cuda:1.0.0
```


# Run

```
docker compose up -d
```

# debug console:

```
docker run --rm -it   --gpus all   --runtime=nvidia   -v ./models:/models -v ./records:/records -p 8080:8080 whisper-server-gpu -h

nvidia-smi
```

# transcribe
```
curl -X POST http://localhost:8080/inference   -F "file=@records/output.wav"   -F "language=ru"   -F "task=transcribe" -F "response_format=verbose_json" > verbose_json.json
curl -X POST http://localhost:8080/inference   -F "file=@records/conf8914_record.raw.ogg"   -F "language=ru"   -F "task=transcribe" -F "response_format=verbose_json" > text/verbose_json_conf8914.json

curl -X POST http://localhost:8080/inference   -F "file=@records/output.wav"   -F "language=ru"   -F "task=transcribe" -F "temperature=0.0" -F "temperature_inc=0.2"  -F "response_format=verbose_json" > verbose_json_temp00.json
curl -X POST http://localhost:8080/inference   -F "file=@records/output.wav"   -F "language=ru"   -F "task=transcribe" -F "temperature=0.1" -F "temperature_inc=0.2"  -F "response_format=verbose_json" > verbose_json_temp01.json
curl -X POST http://localhost:8080/inference   -F "file=@records/output.wav"   -F "language=ru"   -F "task=transcribe" -F "response_format=vtt" > vtt.vtt
curl -X POST http://localhost:8080/inference   -F "file=@records/output.wav"   -F "language=ru"   -F "task=transcribe" -F "response_format=json" > json.json
curl -X POST http://localhost:8080/inference   -F "file=@records/output.wav"   -F "language=ru"   -F "task=transcribe" -F "response_format=srt" > srt.srt
```