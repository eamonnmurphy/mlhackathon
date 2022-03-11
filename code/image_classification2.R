library(keras)
install_keras()
library(jpeg)

# load images
butterfly_loc <- "../data/butterfly/"
ladybird_loc <- "../data/ladybird/"

butterflies <- list.files(butterfly_loc)
ladybirds <- list.files(ladybird_loc)

butterfly_imgs <- lapply(butterflies, function(x) readJPEG(paste0(butterfly_loc,x)))
ladybird_imgs <- lapply(ladybirds, function(x) readJPEG(paste0(ladybird_loc,x)))

# (Stupidly) trim the images down to the 'correct' size
butterfly_imgs <- lapply(butterfly_imgs, function(x) x[1:56,1:56,])
ladybird_imgs <- lapply(ladybird_imgs, function(x) x[1:56,1:56,])

# Pick a single channel out for image analysis
butterfly_imgs <- lapply(butterfly_imgs, function(x) x[,,1])
ladybird_imgs <- lapply(ladybird_imgs, function(x) x[,,1])

# Reformat so that everything is in TensorFlow format
# - (hideously - should be able to do this with abind)

# arr.images.b <- array(NA, dim=c(348,56,56))
# for(i in seq_along(butterfly_imgs)) {
#     arr.images.b[i,,] <- butterfly_imgs[[i]]
# }
# arr.images.l <- array(NA, dim=c(348,56,56))
# for(i in seq_along(ladybird_imgs)) {
#     arr.images.l[i,,] <- ladybird_imgs[[i]]
# }

arr.images <- array(NA, dim = c(696, 56, 56))
for(i in seq_along(butterfly_imgs)){
    arr.images[i,,] <- butterfly_imgs[[i]]
}
for(i in seq(from = 349, to = 696)) {
    arr.images[i,,] <- ladybird_imgs[[i - 348]]
}

labels <- c(rep(0, 348), rep(1, 348))


batch_size <- 5
img_height <- 100
img_width <- 100
set.seed(123)

training <- sample(nrow(arr.images), size = nrow(arr.images) / 2)
arr.images <- arr.images/255


# ?image_dataset_from_directory

#rescaling

#model 

model <- keras_model_sequential() %>%
    # layer_rescaling(1./255) %>%
    layer_conv_2d(filters = 50, kernel_size = c(5,5),
                  activation = 'relu', input_shape = c(56,56,1)) %>%
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

model %>% fit(arr.images[training,,], labels[training], epochs = 2000)

model %>% evaluate(arr.images[-training,,], labels[-training])

predictions <- model %>% predict(arr.images[-training,,])
table(apply(predictions, 1, which.max) - 1, labels[-training])





