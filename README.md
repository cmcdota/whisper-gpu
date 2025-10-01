# install

1) установить [Nvidia CUDA Toolkit](https://developer.nvidia.com/cuda-downloads)
2) проверить что выполняется команда ``nvidia-smi`` и выводит данные о видюхе.
3) Если запускаете из windows, то запустить WSL, установить nvidia cuda ещё и в нём.
4) docker desktop - проверить переключить его на WSL версию с установелнной версией CUDA.
5) В /models положить [ggml-large-v3-turbo.bin](https://huggingface.co/ggerganov/whisper.cpp/blob/main/ggml-large-v3-turbo.bin) скачав со странички https://huggingface.co/ggerganov/whisper.cpp/tree/main
6) Убедиться что есть файл [ggml-silero-v5.1.2.bin](models/ggml-silero-v5.1.2.bin), он хорошо обрабатывает тишину (чтоб транскрибатор не выдавал лишние слова когда молчат)

# debug console:

```
docker run --rm -it   --gpus all   --runtime=nvidia   -v ./models:/models -v ./records:/records -p 8080:8080 whisper-server-gpu -h

nvidia-smi
```

# Проверка транскрибации, отправляя файл output.wav
```
curl -X POST http://localhost:8080/inference   -F "file=@output.wav"   -F "language=ru"   -F "task=transcribe" -F "response_format=verbose_json" > verbose_json.json
```