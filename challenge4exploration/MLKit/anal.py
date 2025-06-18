# import coremltools as ct

# model = ct.models.MLModel("/Users/kerupuksambel/Projects/Academy/challenge4exploration/challenge4exploration/MLKit/ImageDetectorDoodle.mlmodel")
# spec = model.get_spec()

# image_input = spec.description.input[0]
# print(f"Name: {image_input.name}")
# print(f"Type: {image_input.type.WhichOneof('Type')}")
# if image_input.type.WhichOneof("Type") == "imageType":
#     image = image_input.type.imageType
#     print(f"Color space: {image.colorSpace}")  # 10 = GRAYSCALE, 20 = RGB
#     print(f"Width x Height: {image.width} x {image.height}")
#     # print(f"Is BGR: {image.isBgr}")
#     print(f"Scale (normalization): {image.scale}")  # 1.0 means normalized to [0,1]
#     print(f"Bias: {image.bias}")  # Optional offset



import coremltools as ct

model = ct.models.MLModel("/Users/kerupuksambel/Projects/Academy/challenge4exploration/challenge4exploration/MLKit/ImageDetectorDoodle.mlmodel")
spec = model.get_spec()

image_input = spec.description.input[0]
image = image_input.type.imageType

print("Color Space:", image.colorSpace)  # 10 = Grayscale, 20 = RGB
print("Width x Height:", image.width, "x", image.height)
