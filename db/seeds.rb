# frozen_string_literal: true

supplier_a = Supplier.find_or_create_by!(
  name: 'A'
)

supplier_b = Supplier.find_or_create_by!(
  name: 'B'
)

supplier_c = Supplier.find_or_create_by!(
  name: 'C'
)

t_shirt = Product.find_or_create_by!(
  name: 'T-Shirt'
)

hoodie = Product.find_or_create_by!(
  name: 'Hoodie'
)

DeliveryTime.find_or_create_by!(
  region: 'eu',
  supplier: supplier_a,
  product: t_shirt,
  days: 1
)

DeliveryTime.find_or_create_by!(
  region: 'eu',
  supplier: supplier_b,
  product: t_shirt,
  days: 1
)

DeliveryTime.find_or_create_by!(
  region: 'eu',
  supplier: supplier_b,
  product: hoodie,
  days: 1
)

DeliveryTime.find_or_create_by!(
  region: 'eu',
  supplier: supplier_c,
  product: hoodie,
  days: 1
)

Stock.find_or_create_by!(
  supplier: supplier_a,
  product: t_shirt,
  in_stock: 10
)

Stock.find_or_create_by!(
  supplier: supplier_b,
  product: t_shirt,
  in_stock: 10
)

Stock.find_or_create_by!(
  supplier: supplier_b,
  product: hoodie,
  in_stock: 10
)

Stock.find_or_create_by!(
  supplier: supplier_c,
  product: hoodie,
  in_stock: 10
)
