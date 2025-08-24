// cuda_kernels.cu
#include "cuda_runtime.h"
#include "device_launch_parameters.h"
#include "cuda_kernels.h"
#include <algorithm> // Para std::min

// Kernel CUDA para aplicar o filtro Sépia
__global__ void sepiaKernel(unsigned char* input, unsigned char* output, int width, int height, int stride) {
    int x = blockIdx.x * blockDim.x + threadIdx.x;
    int y = blockIdx.y * blockDim.y + threadIdx.y;

    if (x < width && y < height) {
        long offset = (long)y * stride + (long)x * 4; // Assumindo 32bpp (4 bytes: B, G, R, A)

        int b = input[offset];
        int g = input[offset + 1];
        int r = input[offset + 2];
        int a = input[offset + 3];

        float tr = 0.393f * r + 0.769f * g + 0.189f * b;
        float tg = 0.349f * r + 0.686f * g + 0.168f * b;
        float tb = 0.272f * r + 0.534f * g + 0.131f * b;

        // O CÓDIGO CORRIGIDO:
        output[offset] = static_cast<unsigned char>(fminf(255.0f, tb));
        output[offset + 1] = static_cast<unsigned char>(fminf(255.0f, tg));
        output[offset + 2] = static_cast<unsigned char>(fminf(255.0f, tr));
        output[offset + 3] = a;
    }
}

// Kernel CUDA para aplicar o filtro de Inversão de Cores
__global__ void invertKernel(unsigned char* input, unsigned char* output, int width, int height, int stride) {
    int x = blockIdx.x * blockDim.x + threadIdx.x;
    int y = blockIdx.y * blockDim.y + threadIdx.y;

    if (x < width && y < height) {
        long offset = (long)y * stride + (long)x * 4; // Assumindo 32bpp (4 bytes: B, G, R, A)

        output[offset] = 255 - input[offset];     // Inverte o Azul
        output[offset + 1] = 255 - input[offset + 1]; // Inverte o Verde
        output[offset + 2] = 255 - input[offset + 2]; // Inverte o Vermelho
        output[offset + 3] = input[offset + 3];      // Preserva o canal alfa
    }
}


// Função Wrapper para Sépia
void applySepiaFilterCuda(unsigned char* h_input, unsigned char* h_output, int width, int height, int stride) {
    unsigned char* d_input, * d_output;
    size_t imageSize = (size_t)stride * height;

    // 1. Alocar memória na GPU
    cudaMalloc((void**)&d_input, imageSize);
    cudaMalloc((void**)&d_output, imageSize);

    // 2. Copiar imagem da CPU (host) para a GPU (device)
    cudaMemcpy(d_input, h_input, imageSize, cudaMemcpyHostToDevice);

    // 3. Configurar a grade de threads para o kernel
    dim3 threadsPerBlock(16, 16);
    dim3 numBlocks((width + threadsPerBlock.x - 1) / threadsPerBlock.x,
        (height + threadsPerBlock.y - 1) / threadsPerBlock.y);

    // 4. Lançar o kernel na GPU
    sepiaKernel << <numBlocks, threadsPerBlock >> > (d_input, d_output, width, height, stride);

    // Sincronizar para garantir que o kernel terminou antes de copiar de volta
    cudaDeviceSynchronize();

    // 5. Copiar a imagem processada da GPU para a CPU
    cudaMemcpy(h_output, d_output, imageSize, cudaMemcpyDeviceToHost);

    // 6. Liberar memória da GPU
    cudaFree(d_input);
    cudaFree(d_output);
}


// Função Wrapper para Inversão de Cores
void applyInvertFilterCuda(unsigned char* h_input, unsigned char* h_output, int width, int height, int stride) {
    unsigned char* d_input, * d_output;
    size_t imageSize = (size_t)stride * height;

    cudaMalloc((void**)&d_input, imageSize);
    cudaMalloc((void**)&d_output, imageSize);

    cudaMemcpy(d_input, h_input, imageSize, cudaMemcpyHostToDevice);

    dim3 threadsPerBlock(16, 16);
    dim3 numBlocks((width + threadsPerBlock.x - 1) / threadsPerBlock.x,
        (height + threadsPerBlock.y - 1) / threadsPerBlock.y);

    invertKernel << <numBlocks, threadsPerBlock >> > (d_input, d_output, width, height, stride);

    cudaDeviceSynchronize();

    cudaMemcpy(h_output, d_output, imageSize, cudaMemcpyDeviceToHost);

    cudaFree(d_input);
    cudaFree(d_output);
}