import 'package:image_picker/image_picker.dart';

//image picker
pickImage(ImageSource source) async {
  final ImagePicker _imagePicker = ImagePicker();
  XFile? _file = await _imagePicker.pickImage(source: source);
  print('${_file?.path}');
  if (_file != null) {
    return await _file.readAsBytes();
  }
  print('No Image Selected');
}