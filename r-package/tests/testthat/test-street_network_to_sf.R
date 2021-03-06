context("street_network_to_sf")

# setup_r5
path <- system.file("extdata", package = "r5r")
r5_core <- setup_r5(data_path = path, verbose=FALSE)


# expected behavior
test_that("street_network_to_sf - expected behavior", {

  testthat::expect_type( street_network_to_sf(r5_core), 'list')
})



# Expected errors
test_that("street_network_to_sf - expected errors", {

  # invalid input
  testthat::expect_error( street_network_to_sf('a') )
  })
