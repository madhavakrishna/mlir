// RUN: mlir-opt %s | mlir-opt | FileCheck %s

// CHECK-LABEL: func @vector_transfer_ops(
func @vector_transfer_ops(%arg0: memref<?x?xf32>) {
  %c3 = constant 3 : index
  %cst = constant 3.0 : f32
  %f0 = constant 0.0 : f32
  //
  // CHECK: %0 = vector.transfer_read
  %0 = vector.transfer_read %arg0[%c3, %c3], %f0 {permutation_map = (d0, d1)->(d0)} : memref<?x?xf32>, vector<128xf32>
  // CHECK: %1 = vector.transfer_read
  %1 = vector.transfer_read %arg0[%c3, %c3], %f0 {permutation_map = (d0, d1)->(d1, d0)} : memref<?x?xf32>, vector<3x7xf32>
  // CHECK: vector.transfer_read
  %2 = vector.transfer_read %arg0[%c3, %c3], %cst {permutation_map = (d0, d1)->(d0)} : memref<?x?xf32>,  vector<128xf32>
  // CHECK: vector.transfer_read
  %3 = vector.transfer_read %arg0[%c3, %c3], %cst {permutation_map = (d0, d1)->(d1)} : memref<?x?xf32>,  vector<128xf32>
  //
  // CHECK: vector.transfer_write
  vector.transfer_write %0, %arg0[%c3, %c3] {permutation_map = (d0, d1)->(d0)} : vector<128xf32>, memref<?x?xf32>
  // CHECK: vector.transfer_write
  vector.transfer_write %1, %arg0[%c3, %c3] {permutation_map = (d0, d1)->(d1, d0)} : vector<3x7xf32>, memref<?x?xf32>
  return
}

// CHECK-LABEL: @vector_broadcast
func @vector_broadcast(%a: f32, %b: vector<16xf32>, %c: vector<1x16xf32>, %d: vector<8x1xf32>) -> vector<8x16xf32> {
  // CHECK: vector.broadcast %{{.*}} : f32 to vector<16xf32>
  %0 = vector.broadcast %a : f32 to vector<16xf32>
  // CHECK-NEXT: vector.broadcast %{{.*}} : vector<16xf32> to vector<8x16xf32>
  %1 = vector.broadcast %b : vector<16xf32> to vector<8x16xf32>
  // CHECK-NEXT: vector.broadcast %{{.*}} : vector<1x16xf32> to vector<8x16xf32>
  %2 = vector.broadcast %c : vector<1x16xf32> to vector<8x16xf32>
  // CHECK-NEXT: vector.broadcast %{{.*}} : vector<8x1xf32> to vector<8x16xf32>
  %3 = vector.broadcast %d : vector<8x1xf32> to vector<8x16xf32>
  return %3 : vector<8x16xf32>
}

// CHECK-LABEL: @shuffle1D
func @shuffle1D(%a: vector<2xf32>, %b: vector<4xf32>) -> vector<2xf32> {
  // CHECK: vector.shuffle %{{.*}}, %{{.*}}[0 : i32, 1 : i32, 2 : i32, 3 : i32] : vector<2xf32>, vector<2xf32>
  %1 = vector.shuffle %a, %a[0 : i32, 1 : i32, 2: i32, 3 : i32] : vector<2xf32>, vector<2xf32>
  // CHECK-NEXT: vector.shuffle %{{.*}}, %{{.*}}[0 : i32, 1 : i32, 2 : i32] : vector<4xf32>, vector<4xf32>
  %2 = vector.shuffle %1, %b[0 : i32, 1 : i32, 2 : i32] : vector<4xf32>, vector<4xf32>
  // CHECK-NEXT: vector.shuffle %{{.*}}, %{{.*}}[0 : i32, 6 : i32] : vector<3xf32>, vector<4xf32>
  %3 = vector.shuffle %2, %b[0 : i32, 6 : i32] : vector<3xf32>, vector<4xf32>
  return %3 : vector<2xf32>
}

// CHECK-LABEL: @shuffle2D
func @shuffle2D(%a: vector<1x4xf32>, %b: vector<2x4xf32>) -> vector<3x4xf32> {
  // CHECK: vector.shuffle %{{.*}}, %{{.*}}[0 : i32, 1 : i32, 2 : i32] : vector<1x4xf32>, vector<2x4xf32>
  %1 = vector.shuffle %a, %b[0 : i32, 1 : i32, 2: i32] : vector<1x4xf32>, vector<2x4xf32>
  return %1 : vector<3x4xf32>
}

// CHECK-LABEL: @extract_element
func @extract_element(%a: vector<16xf32>) -> f32 {
  // CHECK:      %[[C15:.*]] = constant 15 : index
  %c = constant 15 : index
  // CHECK-NEXT: vector.extractelement %{{.*}}[%[[C15]] : index] : vector<16xf32>
  %1 = vector.extractelement %a[%c : index] : vector<16xf32>
  return %1 : f32
}

// CHECK-LABEL: @extract
func @extract(%arg0: vector<4x8x16xf32>) -> (vector<8x16xf32>, vector<16xf32>, f32) {
  // CHECK: vector.extract {{.*}}[3 : i32] : vector<4x8x16xf32>
  %1 = vector.extract %arg0[3 : i32] : vector<4x8x16xf32>
  // CHECK-NEXT: vector.extract {{.*}}[3 : i32, 3 : i32] : vector<4x8x16xf32>
  %2 = vector.extract %arg0[3 : i32, 3 : i32] : vector<4x8x16xf32>
  // CHECK-NEXT: vector.extract {{.*}}[3 : i32, 3 : i32, 3 : i32] : vector<4x8x16xf32>
  %3 = vector.extract %arg0[3 : i32, 3 : i32, 3 : i32] : vector<4x8x16xf32>
  return %1, %2, %3 : vector<8x16xf32>, vector<16xf32>, f32
}

// CHECK-LABEL: @insert_element
func @insert_element(%a: f32, %b: vector<16xf32>) -> vector<16xf32> {
  // CHECK:      %[[C15:.*]] = constant 15 : index
  %c = constant 15 : index
  // CHECK-NEXT: vector.insertelement %{{.*}}, %{{.*}}[%[[C15]] : index] : vector<16xf32>
  %1 = vector.insertelement %a, %b[%c : index] : vector<16xf32>
  return %1 : vector<16xf32>
}

// CHECK-LABEL: @insert
func @insert(%a: f32, %b: vector<16xf32>, %c: vector<8x16xf32>, %res: vector<4x8x16xf32>) -> vector<4x8x16xf32> {
  // CHECK: vector.insert %{{.*}}, %{{.*}}[3 : i32] : vector<8x16xf32> into vector<4x8x16xf32>
  %1 = vector.insert %c, %res[3 : i32] : vector<8x16xf32> into vector<4x8x16xf32>
  // CHECK: vector.insert %{{.*}}, %{{.*}}[3 : i32, 3 : i32] : vector<16xf32> into vector<4x8x16xf32>
  %2 = vector.insert %b, %res[3 : i32, 3 : i32] : vector<16xf32> into vector<4x8x16xf32>
  // CHECK: vector.insert %{{.*}}, %{{.*}}[3 : i32, 3 : i32, 3 : i32] : f32 into vector<4x8x16xf32>
  %3 = vector.insert %a, %res[3 : i32, 3 : i32, 3 : i32] : f32 into vector<4x8x16xf32>
  return %3 : vector<4x8x16xf32>
}

// CHECK-LABEL: @outerproduct
func @outerproduct(%arg0: vector<4xf32>, %arg1: vector<8xf32>, %arg2: vector<4x8xf32>) -> vector<4x8xf32> {
  // CHECK: vector.outerproduct {{.*}} : vector<4xf32>, vector<8xf32>
  %0 = vector.outerproduct %arg0, %arg1 : vector<4xf32>, vector<8xf32>
  // CHECK: vector.outerproduct {{.*}}, {{.*}}, {{.*}} : vector<4xf32>, vector<8xf32>
  %1 = vector.outerproduct %arg0, %arg1, %arg2 : vector<4xf32>, vector<8xf32>
  return %1 : vector<4x8xf32>
}

// CHECK-LABEL: @insert_strided_slice
func @insert_strided_slice(%a: vector<4x4xf32>, %b: vector<4x8x16xf32>) {
  // CHECK: vector.insert_strided_slice %{{.*}}, %{{.*}} {offsets = [2, 2, 2], strides = [1, 1]} : vector<4x4xf32> into vector<4x8x16xf32>
  %1 = vector.insert_strided_slice %a, %b {offsets = [2, 2, 2], strides = [1, 1]} : vector<4x4xf32> into vector<4x8x16xf32>
  return
}

// CHECK-LABEL: @strided_slice
func @strided_slice(%arg0: vector<4x8x16xf32>) -> vector<2x2x16xf32> {
  // CHECK: vector.strided_slice %{{.*}} {offsets = [2, 2], sizes = [2, 2], strides = [1, 1]} : vector<4x8x16xf32>
  %1 = vector.strided_slice %arg0 {offsets = [2, 2], sizes = [2, 2], strides = [1, 1]} : vector<4x8x16xf32> to vector<2x2x16xf32>
  return %1: vector<2x2x16xf32>
}

#contraction_accesses0 = [
  (b0, f0, f1, c0, c1) -> (c0, b0, c1, f0),
  (b0, f0, f1, c0, c1) -> (b0, c1, c0, f1),
  (b0, f0, f1, c0, c1) -> (b0, f0, f1)
]
#contraction_trait0 = {
  indexing_maps = #contraction_accesses0,
  iterator_types = ["parallel", "parallel", "parallel", "reduction", "reduction"]
}
#contraction_accesses1 = [
  (f0, f1, f2, f3, c0, c1) -> (c0, f0, c1, f2),
  (f0, f1, f2, f3, c0, c1) -> (f1, c1, c0, f3),
  (f0, f1, f2, f3, c0, c1) -> (f0, f1, f2, f3)
]
#contraction_trait1 = {
  indexing_maps = #contraction_accesses1,
  iterator_types = ["parallel", "parallel", "parallel", "parallel", "reduction",
                    "reduction"]
}
// CHECK-LABEL: contraction
func @contraction(%arg0 : vector<7x8x16x15xf32>, %arg1 : vector<8x16x7x5xf32>,
                  %arg2 : vector<8x15x5xf32>, %arg3 : vector<8x15x8x5xf32>,
                  %arg4 : index) {
  // Test contraction with batch and contracting dims.
  // CHECK: vector.contract {indexing_maps = [#{{.*}}, #{{.*}}, #{{.*}}], iterator_types = ["parallel", "parallel", "parallel", "reduction", "reduction"]} {{.*}}, {{.*}}, {{.*}} : vector<7x8x16x15xf32>, vector<8x16x7x5xf32> into vector<8x15x5xf32>
  %0 = vector.contract #contraction_trait0 %arg0, %arg1, %arg2
      : vector<7x8x16x15xf32>, vector<8x16x7x5xf32> into vector<8x15x5xf32>
  // Test contraction with only contracting dims. In this case the lhs/rhs
  // dimension of size 8 will be considered a parallel dim for lhs/rhs and will
  // appear twice in the output.
  // CHECK: vector.contract {indexing_maps = [#{{.*}}, #{{.*}}, #{{.*}}], iterator_types = ["parallel", "parallel", "parallel", "parallel", "reduction", "reduction"]} {{.*}}, {{.*}}, {{.*}} : vector<7x8x16x15xf32>, vector<8x16x7x5xf32> into vector<8x15x8x5xf32>
  %1 = vector.contract #contraction_trait1 %arg0, %arg1, %arg3
      : vector<7x8x16x15xf32>, vector<8x16x7x5xf32> into vector<8x15x8x5xf32>
  // Test contraction with optional vector mask arguments.
  %lhs_mask = vector.constant_mask [7, 8, 16, 15] : vector<7x8x16x15xi1>
  %rhs_mask = vector.constant_mask [8, 16, 7, 5] : vector<8x16x7x5xi1>
  // CHECK: vector.contract {indexing_maps = [#{{.*}}, #{{.*}}, #{{.*}}], iterator_types = ["parallel", "parallel", "parallel", "parallel", "reduction", "reduction"]} {{.*}}, {{.*}}, {{.*}}, {{.*}}, {{.*}} : vector<7x8x16x15xf32>, vector<8x16x7x5xf32> into vector<8x15x8x5xf32>
  %2 = vector.contract #contraction_trait1 %arg0, %arg1, %arg3, %lhs_mask,
                                           %rhs_mask
      : vector<7x8x16x15xf32>, vector<8x16x7x5xf32> into vector<8x15x8x5xf32>
  return
}

// CHECK-LABEL: create_vector_mask
func @create_vector_mask() {
  // CHECK:      %[[C2:.*]] = constant 2 : index
  %c2 = constant 2 : index
  // CHECK-NEXT: %[[C3:.*]] = constant 3 : index
  %c3 = constant 3 : index
  // CHECK-NEXT: vector.create_mask %[[C3]], %[[C2]] : vector<4x3xi1>
  %0 = vector.create_mask %c3, %c2 : vector<4x3xi1>

  return
}

// CHECK-LABEL: constant_vector_mask
func @constant_vector_mask() {
  // CHECK: vector.constant_mask [3, 2] : vector<4x3xi1>
  %0 = vector.constant_mask [3, 2] : vector<4x3xi1>
  return
}

// CHECK-LABEL: extract_slices
func @extract_slices(%arg0 : vector<4x2xf32>)
  -> (tuple<vector<2x2xf32>, vector<2x2xf32>>) {
  // CHECK: vector.extract_slices %{{.*}}, [2, 2], [1, 1] : vector<4x2xf32> into tuple<vector<2x2xf32>, vector<2x2xf32>>
  %0 = vector.extract_slices %arg0, [2, 2], [1, 1]
    : vector<4x2xf32> into tuple<vector<2x2xf32>, vector<2x2xf32>>
  %1 = vector.tuple_get %0, 0 : tuple<vector<2x2xf32>, vector<2x2xf32>>
  %2 = vector.tuple_get %0, 1 : tuple<vector<2x2xf32>, vector<2x2xf32>>
  %3 = vector.tuple %1, %2 : vector<2x2xf32>, vector<2x2xf32>
  return %3 : tuple<vector<2x2xf32>, vector<2x2xf32>>
}

// CHECK-LABEL: insert_slices
func @insert_slices(%arg0 : tuple<vector<2x2xf32>, vector<2x2xf32>>)
  -> (vector<4x2xf32>) {
  // CHECK: vector.insert_slices %{{.*}}, [2, 2], [1, 1] : tuple<vector<2x2xf32>, vector<2x2xf32>> into vector<4x2xf32>
  %0 = vector.insert_slices %arg0, [2, 2], [1, 1]
    : tuple<vector<2x2xf32>, vector<2x2xf32>> into vector<4x2xf32>
  return %0 : vector<4x2xf32>
}
