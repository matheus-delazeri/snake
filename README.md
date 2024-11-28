O presente trabalho apresenta o desenvolvimento do clássico "Jogo da Cobra"(Snake Game) utilizando a linguagem Assembly MIPS.

## Como Rodar o Jogo

### Requisitos

1. **Software Mars**: Certifique-se de ter o simulador MIPS Mars instalado em seu computador. Ele pode ser baixado [aqui]([https://courses.missouristate.edu/kenvollmar/mars/](https://dpetersanderson.github.io/)).
2. **Arquivos Necessários**: Faça o download dos arquivos `main.asm` e `display_bitmap.asm` disponíveis neste repositório: [GitHub - Snake Game](https://github.com/matheus-delazeri/snake/blob/main/main.asm).

### Etapas para Execução

1. **Abra o arquivo no Mars**: Inicie o software Mars e abra o arquivo `main.asm`.
2. **Configure o Bitmap Display**:
   - No menu do Mars, vá para **Tools** > **Bitmap Display**.
   - Configure o display conforme as especificações abaixo:
     - **Unit Width in pixels**: 8
     - **Unit Height in pixels**: 8
     - **Display Width in pixels**: 512
     - **Display Height in pixels**: 512
   - Pressione **Connect to MIPS** para associar o display ao programa.
     
     ![image](https://github.com/user-attachments/assets/acebebf1-3f4b-4d28-9e82-534d3b01619b)

3. **Configure o Keyboard Simulator**:
   - No menu do Mars, vá para **Tools** > **Keyboard and Display MMIO Simulator**.
   - Pressione **Connect to MIPS** para que o teclado funcione em conjunto com o programa.
  
     ![image](https://github.com/user-attachments/assets/c8047c38-a7f9-4e4f-8f4e-bbfb4805900d)

4. **Inicie o Jogo**:
   - Com todas as ferramentas configuradas, execute o programa clicando em **Assemble** e posteriormente em **Run**.
  
     ![image](https://github.com/user-attachments/assets/6625696f-4392-43f3-bece-83b723eb5af3)

### Controles do Jogo

Use as teclas para mover a cobra:
- `W`: Mover para cima.
- `S`: Mover para baixo.
- `A`: Mover para a esquerda.
- `D`: Mover para a direita.
- `Q`: Sair do jogo.

### Considerações

- Certifique-se de que o display e o teclado estão conectados ao MIPS antes de iniciar o jogo.
- Se o jogo terminar (ao colidir com a parede ou com a própria cobra), será necessário realizar o passo **4** para jogar novamente.
