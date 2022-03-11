library(keras)
install_keras()



#bee <- list.files("../data/testdata", pattern = ".jpg", all.files = TRUE,
                  full.names = TRUE)


batch_size <- 5
img_height <- 100
img_width <- 100

data_dir <- "../data/"

train_ds <- image_dataset_from_directory(
  data_dir,
  validation_split = 0.2,
  subset = "training",
  seed = 123,
  image_size = c(img_height, img_width),
  batch_size = batch_size)

val_ds <- image_dataset_from_directory(
  data_dir,
  validation_split = 0.2,
  subset = "validation",
  seed = 123,
  image_size = c(img_height, img_width),
  batch_size = batch_size)
)

#rescaling

#model 

model <- keras_model_sequential() %>%
  layer_rescaling(1./255) %>%
  layer_conv_2d(filters = 20, kernel_size = c(3,3),
                activation = 'relu', input_shape = c(img_height, img_width,1)) %>%
  layer_max_pooling_2d(pool_size = c(2,2)) %>%
    #layer_dropout(rate = 0.25) %>%
    layer_flatten() %>%
    layer_dense(units = 20, activation = 'relu') %>%
    layer_dense(units = 2, activation = 'softmax') %>%
    compile(
      optimizer = 'adam',
      loss = 'sparse_categorical_crossentropy',
      metrics = c('accuracy')
    )

model %>% fit(train_ds, epochs = 5)

model %>% evaluate(val_ds)

predictions <- model %>% predict(val_ds)
table(apply(predictions, 1, which.max) - 1)


