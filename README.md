BuddhaBrot-Fractal-in-OpenGL-and-Haskell
========================================

This is a project made in Haskell and OpenGL, consisting of a BuddhaBrot fractal. For representing the pixels, I used coordinates as complex numbers, although the Data.Complex Library was not imported. In fact, I did my own Complex data type, for handling all the complex operations needed properly for the project. Moreover, it is faster when rendering the image.

I have tested more cases by taking several values for the number of iterations and the size of the drawing image. For higher values of the size and number of iterations, the program will run slower, while for smaller values it will be faster, however the quality of the image will be much lower. Also, there are color multipliers for red, green and blue, which could be modified in order to set another color of the final image.

The code is already compiled using 'ghc --make buddha.hs -rtsopts' command. So, for higher values of the image size, the program with standard ghc stack size should give a stack overflow. For increasing the size of the stack for higher values (and, as well, for a clearer image), execute the program using the following command in the Terminal : './buddha + -Ksize ', where `size` is the new size of the stack you want to set. For example, I usually use 100MB for rendering higher-quality images (also, it will take much longer to compile): ----- './buddha +RTS -K100M'. -----

Moreover, the folder contains more images, with more values for the number of iterations. The first image has all the numbers in mandelbrot set checked for 10 iterations, and the last one has 1000 iterations and size 500x500 (I increased the size of the stack for this).
