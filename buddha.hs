--imports--
import Graphics.Rendering.OpenGL
import Graphics.UI.GLUT
import Data.IORef
import Data.List
import Data.Char
import Data.Array.Unboxed
-----------

wSize = Size 600 600 --size of the drawing OpenGL window
maxIterations = 1000 :: Int --maximum number of iterations for the mandelbrot set of points; set it bigger for a clearer image

--Width and Height of the buddhabrot image... set them bigger for a bigger and clearer image
width = 500 :: Int --setting the width of the mandelbrot image
height = 500 :: Int --setting the height of the mandelbrot image

redM = 0.4 -- multiplier for Red color 				
greenM = 0.6 -- multiplier for Green color
blueM = 1.0 -- multiplier for Blue color

-- Implementing our own complex data type.. it is more efficient and the rendering will be faster

data Complex = C GLfloat GLfloat deriving (Show, Eq)

instance Num Complex where
    fromInteger n = C (fromIntegral n) 0.0
    (C x y) * (C z t) = C (z*x - y*t) (y*z + x*t)
    (C x y) + (C z t) = C (x+z) (y+t)
    abs (C x y) = C (x*x+y*y) 0.0
    signum (C x y) = C (signum x) (0.0)

-- Also, we implement our own functions which will be useful for manipulating complex numbers

real :: Complex -> GLfloat
real (C x y) = x

im :: Complex -> GLfloat
im (C x y) = y

magnitude :: Complex -> GLfloat
magnitude = real.abs
---------------------------------------------------------------------------------------------



main :: IO () --main function
main = do
	(progname,_) <-getArgsAndInitialize
	initialDisplayMode $= [DoubleBuffered] --we set the display mode to be Double Buffered
	createWindow "Buddhabrot fractal" -- creating the drawing window in OpenGL
	windowSize $= wSize -- setting the size of the drawing window
	displayCallback $= do
		clear [ColorBuffer]
		loadIdentity
		preservingMatrix drawPic
		swapBuffers
	mainLoop
-----------------------------------------------------------------------------------------------

--Functions used for rendering the BuddhaBrot--

convertToGL :: Int -> GLfloat --function made to convert integers to GLfloat special numbers
convertToGL = fromIntegral

floatToGL :: Float -> GLfloat --function that converts Float numbers to GLfloat special numbers
floatToGL = realToFrac

drawPic :: IO () --the function used to render the mandelbrot image with pixels having coordinates from the finalBuddhaPointsList 
drawPic  = renderPrimitive Points $ do	
			mapM_ drawing finalBuddhaPointsList
				where 
				  drawing (x,y,c) = do
				  color c
				  vertex $ Vertex2 x y

isFunc :: Complex ->Complex ->Int->Bool --function that checks recursively if a point with given coords is part of the mandelbrot set for given number of iterations
isFunc c z 0 = False
isFunc c z n = if ((magnitude z) > 2) then True
				else  isFunc c ((z*z)+c) (n-1) 

isMandel :: GLfloat->GLfloat->Bool --function that checks if a point with given coords is in the mandelbrot set 
isMandel x y = (isFunc (C (2*x/(convertToGL width)) (2*y/(convertToGL height))) (C 0 0) maxIterations ) 

isOutside :: GLfloat->GLfloat->Bool
isOutside x y = x > p - 2 * p^2 + 1/4
	where p = sqrt ((x - 1/4)^2 + y^2)

filterMandelPoints :: [(GLfloat,GLfloat)] --function that filters the points in the mandelbrot set from all the other points of the drawing area
filterMandelPoints = filter ( \(ax,ay) -> (isOutside ax ay && isMandel ax ay) ) [(a,b)| a<-[convertToGL(-width)..convertToGL (width)],b<-[convertToGL (-height)..convertToGL (height)]]

mandelPoints :: Complex -> Complex ->Int -> [(GLfloat,GLfloat)] --function that generates the points contained in the mandelbrot set
mandelPoints c z 0 = []
mandelPoints c z numOfIterations = if ( (magnitude z) > 2) then []
					else  if (real (z)/=0 || im(z)/=0 ) then (real (z),im(z)) : (mandelPoints c ((z*z)+c) (numOfIterations-1) )
					else ( [] ++ (mandelPoints c ((z*z)+c) (numOfIterations-1) ) )

buddhaArrayPoints :: Array (Int,Int) Int --function that creates the array of 
buddhaArrayPoints = accumArray (+) 0 ((-width,-height),(width,height)) [((round (x*(convertToGL width)/2),round (y* (convertToGL height)/2)),1)|(x,y)<-concatMap ( \(a,b)->mandelPoints ( C (2*a/(convertToGL width)) (2*b/(convertToGL height))) (C 0 0)  maxIterations) filterMandelPoints]

generateColor :: GLfloat->Int->Color3 GLfloat --function that generates color for appropriate pixels
generateColor maxCol col = Color3 (redM * (a)) (greenM * (a)) (blueM * (a))
	where 
	  a = realToFrac ( (sqrt $ fromIntegral col) / (sqrt  maxCol) )

finalBuddhaPointsList :: [(GLfloat,GLfloat, Color3 GLfloat)] --function for taking the final set of points contained in the mandelbrot set with appropriate colors
finalBuddhaPointsList = [((convertToGL y)/(convertToGL height), (convertToGL (-x))/(convertToGL width), generateColor maxColor c) | 
			((x,y),c) <- assocs buddhaArrayPoints]
	where
	  maxColor = convertToGL $ maximum $ elems buddhaArrayPoints


