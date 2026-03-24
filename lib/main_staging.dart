import 'package:chatbot/core/utils/enums.dart';
import 'package:chatbot/flavor_config.dart';
import 'package:chatbot/main.dart';

void main() async {
  FlavorConfig.instantiate(
    flavor: Flavor.staging,
    baseUrl: "",
    appTitle: 'Chatbot App Staging',
  );
  chatbot();
}
