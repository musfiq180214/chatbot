import 'package:chatbot/core/utils/enums.dart';
import 'package:chatbot/flavor_config.dart';
import 'package:chatbot/main.dart';

void main() async {
  FlavorConfig.instantiate(
    flavor: Flavor.production,
    baseUrl: "",
    appTitle: 'Chatbot App',
  );
  chatbot();
}
