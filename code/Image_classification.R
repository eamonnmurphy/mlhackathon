library(keras)
install_keras()



bee <- list.files("../data/testdata", pattern = ".jpg", all.files = TRUE,
                  full.names = TRUE)

batch_size <- 5
img_height <- 180
img_width <- 180

train_ds <- image_dataset_from_directory(
  "../data/testdata/",
  validation_split = 0.2,
  subset = "training",
  seed = 123,
  image_size = c(img_height, img_width),
  batch_size = batch_size)

#val_ds <-...

#rescaling

#model 


