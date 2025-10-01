# ============ СТАДИЯ СБОРКИ ============
ARG CUDA_VERSION=12.9.0
ARG UBUNTU_VERSION=22.04
FROM nvidia/cuda:${CUDA_VERSION}-devel-ubuntu${UBUNTU_VERSION} AS build

WORKDIR /app

RUN apt-get update && \
    apt-get install -y build-essential cmake git wget ffmpeg libsdl2-dev && \
    rm -rf /var/lib/apt/lists/*

# Настройка CUDA и GGML
ENV GGML_CUDA=1

#TODO: Тут (и ниже в cmake) подправить версию CUDA под вашу версию видеокарты! Подробнее: https://docs.nvidia.com/cuda/cuda-compiler-driver-nvcc/#base-notation
ENV CMAKE_CUDA_ARCHITECTURES=89
# RTX 5080 (Ada)
ENV CUDACXX=/usr/local/cuda/bin/nvcc
ENV LD_LIBRARY_PATH=/usr/local/cuda/lib64/stubs:/usr/local/cuda/lib64:$LD_LIBRARY_PATH
ENV LIBRARY_PATH=/usr/local/cuda/lib64/stubs:/usr/local/cuda/lib64:$LIBRARY_PATH

# Сборка whisper.cpp с API и CUDA
RUN git clone https://github.com/ggerganov/whisper.cpp.git . && \
    cmake -B build \
          -DGGML_CUDA=1 \
          -DWHISPER_BUILD_SERVER=ON \
          -DCMAKE_CUDA_ARCHITECTURES=89 \
          -DGGML_BUILD_BENCHMARK=OFF \
          -DCMAKE_EXE_LINKER_FLAGS="-L/usr/local/cuda/lib64/stubs -lcuda" && \
    cmake --build build -j

# ============ СТАДИЯ РАНТАЙМ ============
FROM nvidia/cuda:${CUDA_VERSION}-runtime-ubuntu${UBUNTU_VERSION}

WORKDIR /app

#Хорошо бы установить ffmpeg чтобы работала опция --convert. Насчет установки wget не уверен что он нужен.
RUN apt-get update && \
    apt-get install -y ffmpeg wget && \
    rm -rf /var/lib/apt/lists/*

# Копируем собранный сервер
COPY --from=build /app /app

# Открываем порт API
EXPOSE 8080

# Старт сервера
ENTRYPOINT ["/app/build/bin/whisper-server"]

#p = количество процессорных ядер
#t = количество потоков
#--convert = говорим конвертировать аудио в пригодный для виспера формат, при необъодимости.
#--vad = говорим использовать VAD (Voice Activity Detection)
CMD ["-m", "/models/ggml-large-v3-turbo.bin", "-p", "2", "-t", "16", "--convert", "--vad","--vad-threshold", "0.55","--vad-min-speech-duration-ms", "300","--vad-min-silence-duration-ms", "250","--vad-max-speech-duration-s", "30","--vad-speech-pad-ms", "50", "--port", "8080", "--host", "0.0.0.0"]
