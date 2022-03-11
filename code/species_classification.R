

# Convolutional model for species classification
conv <- keras_model_sequential() %>%
  layer_conv_2d(filters = 20, kernel_size = c(3,3), activation = "relu",
                input_shape = c(100,100,1)) %>%
  layer_max_pooling_2d(pool_size = c(2,2)) %>%
  #layer_dropout(rate = 0.5) %>%
  layer_flatten() %>%
  layer_dense(units = 20, activation = "relu") %>%
  layer_dense(units = 10, activation = "softmax") %>%
  compile(
    optimizer = "adam",
    loss = "sparse_categorical_crossentropy",
    metrics = c("accuracy")
  )

array.x_train <- array(x_train, dim = c(dim(x_train), 1))

# Image randomisation / augmentation
for(i in 1:20){
  # Randomly alter the training data
  augmented <- array.exp + rnorm(length(as.numeric(exp)), sd=.1)
  # Train once on new data
  conv %>% fit(augmented, resp, epochs=1)
}

# Validate model
conv %>% evaluate(x_test, y_test)
predictions <- conv %>% predict(x_test)
table(apply(predictions, 1, which.max) - 1, y_test)