rm(list =ls())

library(tidyverse)
library(keras)
#install_keras()
library(tensorflow)
#remotes::install_github("maju116/platypus")
library(platypus)
library(magick)
library(png)
library(jpeg)

# selecting 1000 random images

################# BE VERY CAREFUL WHAT DIRECTORY YOU ARE IN 

images <- list.files('../data/Pet_dataset/images')
number <- seq(1, length(images),1)
images <- as.data.frame(cbind(number, images))
test <- sample(images$number, 1000)
images2 <- subset(images, number %in% test)
annotations <- list.files()
annotations <- as.data.frame(cbind(number, annotations))
annotation2 <- subset(annotations, number %in% test)

####### set working directory to images directory

file.copy(from=images2$images, to="../imagesubset")

###### set working directory to annotations directory 

file.copy(from=annotation2$annotations, to="../annotationssubset")


# We now have 2 folders (imagessubset and annotationssubset) which contain 1000 images 

######################

######################

#### BE IN CODE DIRECTORY 

convert_batch <- function(x){
  mask1 <- readPNG(paste0("../data/Pet_dataset/annotationssubset/",x))
  mask1 <- (mask1*255-1)/2
  mask1 <- ifelse(mask1<0.3 | mask1>0.7,1,0)
  writeJPEG(mask1, target = paste0("../data/Pet_dataset/annotationssubset_jpg/",
                                   strsplit(x,".",fixed=T)[[1]][[1]],".jpg"), quality = 1)
}

sapply(dir("../data/Pet_dataset/annotationssubset/"),convert_batch)


#  check whether there are any images in the “annotations_jpg” folder that are not contained in the “images” folder

table(dir("../data/Pet_dataset/annotationssubset_jpg/") %in% dir("../data/Pet_dataset/imagesubset/"))

table(dir("../data/Pet_dataset/imagesubset/") %in% dir("../data/Pet_dataset/annotationssubset_jpg/"))

# removing the three files 

dir("../data/Pet_dataset/imagesubset/")[which(!dir("../data/Pet_dataset/imagesubset/") %in% dir("../data/Pet_dataset/annotationssubset_jpg/"))] 

# Train the u-net model

batch_size <- 32
size <- 256
n_training <- length(dir("../data/Pet_dataset/imagesubset/"))

test_unet <- u_net(size,size,
                   grayscale = F,
                   blocks = 4,
                   n_class = 2 #background + foreground
)

test_unet %>% compile(optimizer = optimizer_adam(lr=0.001),
                      loss = loss_dice(),
                      metrics = metric_dice_coeff())

test_unet

# training with the cat and dog dataset
# define the data generator, specifying the locations of our images and masks and setting some additional parameters

trinity_colormap <- list( # !!! changed the default colormap = binary_colormap
  c(0,0,0), c(128,128,128), c(255,255,255)
)

datagen <- segmentation_generator(
  path = "../data/Pet_dataset",
  colormap = binary_colormap,
  only_images = F,
  mode = "dir",
  net_h = size, net_w = size,
  grayscale = F,
  batch_size = batch_size,
  shuffle = F,
  subdirs = c("/images", "/annotations_jpg")
)


image1 <- readJPEG("../data/Pet_dataset/images/Abyssinian_2.jpg")
mask1 <- readJPEG("../data/Pet_dataset/annotations_jpg/Abyssinian_2.jpg")
table(mask1)

# training the model with 5 epochs

history <- test_unet %>%
  fit_generator(
    datagen,
    epochs = 5,
    steps_per_epoch = n_training %/% batch_size,
    verbose = 2
  )

# saving model weights
save_model_weights_tf(test_unet, "unet_model_weights")

# testing the model 

cat <- image_load("../data/Pet_dataset/images/Egyptian_Mau_4.jpg", target_size = c(size,size))

cat %>%
  image_to_array() %>% 
  `/`(255) %>%
  as.raster() %>%
  plot()

# Let the model generate a mask for this cat:
  
  x <- cat %>% 
  image_to_array() %>%
  array_reshape(., c(1, dim(.))) %>%
  `/`(255)

mask <- test_unet %>% predict(x) %>%
  get_masks(binary_colormap)

plot(as.raster(mask[[1]]/255))

