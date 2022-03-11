rm(list = ls())
library(keras)
# install_keras()



#bee <- list.files("../data/testdata", pattern = ".jpg", all.files = TRUE,
                  # full.names = TRUE)


batch_size <- 5
img_height <- 256
img_width <- 256

data_dir <- "../data/"

train_ds <- image_dataset_from_directory(
  data_dir,
  validation_split = 0.2,
  subset = "training",
  seed = 1,
  image_size = c(img_height, img_width),
  batch_size = batch_size)

val_ds <- image_dataset_from_directory(
  data_dir,
  validation_split = 0.2,
  subset = "validation",
  seed = 1,
  image_size = c(img_height, img_width),
  batch_size = batch_size
)


#rescaling

#model 

conv_model1 <- keras_model_sequential() %>%
  layer_rescaling(1./255) %>%
  layer_conv_2d(filters = 50, kernel_size = c(5,5),
                activation = 'relu', input_shape = c(img_height, img_width,1)) %>%
  layer_max_pooling_2d(pool_size = c(3,3)) %>%
  #layer_dropout(rate = 0.25) %>%
  layer_flatten() %>%
  layer_dense(units = 20, activation = 'relu') %>%
  layer_dense(units = 2, activation = 'softmax') %>%
  compile(
    optimizer = 'adam',
    loss = 'sparse_categorical_crossentropy',
    metrics = c('accuracy')
  )

conv_model1 %>% fit(train_ds, epochs = 10)
conv_model1_metrics <- conv_model1 %>% evaluate(val_ds)

model2 <- keras_model_sequential() %>%
  layer_rescaling(1./256) %>%
  layer_flatten() %>%
  layer_dense(units = 128, activation = 'relu') %>%
  #layer_dropout(rate = 0.5) %>%
  layer_dense(units = 10, activation = "relu") %>%
  layer_dense(units = 2, activation = 'softmax') %>%
  compile(
    optimizer = 'adam',
    loss = 'sparse_categorical_crossentropy',
    metrics = c('accuracy')
  )

model2 %>% fit(train_ds, epochs = 5)
model2_metrics <- model2 %>% evaluate(val_ds)

predictions <- model %>% predict(val_ds)
table(apply(predictions, 1, which.max) - 1, )