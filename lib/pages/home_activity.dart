import 'package:alan_voice/alan_voice.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:radio_fm/utils/ai_util.dart';
import 'package:velocity_x/velocity_x.dart';
import '../model/radio.dart';
import 'package:assets_audio_player/assets_audio_player.dart';

class HomeActivity extends StatefulWidget {
  const HomeActivity({Key? key}) : super(key: key);

  @override
  State<HomeActivity> createState() => _HomeActivityState();
}

class _HomeActivityState extends State<HomeActivity> {
  List<MyRadio> radios = [];
  MyRadio? _selectedRadio;
  bool isPlaying = false;
  final assetsAudioPlayer = AssetsAudioPlayer();

  @override
  void initState() {
    setUpAlan();
    fetchRadios();
    super.initState();
  }

  setUpAlan(){
    AlanVoice.addButton(
        "52a4f4d37d053c9b14c6978622dc96fc2e956eca572e1d8b807a3e2338fdd0dc/stage",
        buttonAlign: AlanVoice.BUTTON_ALIGN_RIGHT);
    AlanVoice.callbacks.add((command) => _handleCommand(command.data));
  }
  _handleCommand(Map<String, dynamic> response) {
    switch (response["command"]) {
      case "play":
        _playMusic(radios[0].url!);
        break;
      default:
        print("Command was ${response["command"]}");
        break;
    }
  }

  fetchRadios() async {
    final radioJson = await rootBundle.loadString("assets/radio.json");
    radios = MyRadioList.fromJson(radioJson).radios!;
    _selectedRadio = radios[0];
  }

  _playMusic(String url) async {
    try {
      await assetsAudioPlayer.open(
        Audio.network(url),
      );
      _selectedRadio = radios.firstWhere((element) => element.url == url);
      print(_selectedRadio!.name);
      isPlaying = true;
      setState(() {});
    } catch (t) {
      print(t);
      //mp3 unreachable
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: Drawer(),
      body: Stack(
        fit: StackFit.expand,
        clipBehavior: Clip.antiAlias,
        children: [
          VxAnimatedBox()
              .size(context.screenWidth, context.screenHeight)
              .withGradient(LinearGradient(
                  colors: [AIColors.primaryColor1, AIColors.primaryColor2],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight))
              .make(),
          AppBar(
            title: "AI Radio".text.xl4.bold.white.make().shimmer(
                primaryColor: Vx.purple300, secondaryColor: Colors.white),
            backgroundColor: Colors.transparent,
            elevation: 0.0,
            centerTitle: true,
          ).h(100.0).p16(),
          VxSwiper.builder(
            itemCount: radios.length,
            aspectRatio: 1.0,
            enlargeCenterPage: true,
            itemBuilder: (context, index) {
              return VxBox(
                child: ZStack(
                  [
                    Positioned(
                        top: 0.0,
                        right: 0.0,
                        child: VxBox(
                          child: radios[index]
                              .category!
                              .text
                              .uppercase
                              .white
                              .make()
                              .px16(),
                        )
                            .height(40)
                            .black
                            .alignCenter
                            .withRounded(value: 10.0)
                            .make()),
                    Align(
                      alignment: Alignment.bottomCenter,
                      child: VStack(
                        [
                          radios[index].name!.text.xl3.white.bold.make(),
                          5.heightBox,
                          radios[index].tagline!.text.sm.white.semiBold.make(),
                        ],
                        crossAlignment: CrossAxisAlignment.center,
                      ),
                    ),
                    Align(
                      alignment: Alignment.center,
                      child: [
                        const Icon(
                          CupertinoIcons.play_circle,
                          color: Colors.white,
                        ),
                        10.heightBox,
                        "Double tap to play".text.gray300.make(),
                      ].vStack(),
                    ),
                  ],
                ),
              )
                  .clip(Clip.antiAlias)
                  .bgImage(DecorationImage(
                      image: NetworkImage(radios[index].image!),
                      fit: BoxFit.cover,
                      colorFilter: ColorFilter.mode(
                          Colors.black.withOpacity(0.3), BlendMode.darken)))
                  .border(color: Colors.black, width: 5.0)
                  .withRounded(value: 16.0)
                  .make()
                  .onInkDoubleTap(() {
               _playMusic(radios[index].url!);
               setState(() {
                 isPlaying = true;
               });
              }).p16();
            },
          ).centered(),
           Align(
             alignment: Alignment.bottomCenter,
             child:[
               isPlaying ? "Playing now - ${_selectedRadio!.name} FM".text.white.makeCentered():const SizedBox(),
               Icon(isPlaying ? CupertinoIcons.stop_circle : CupertinoIcons.play_circle,
                 color: Colors.white,
                 size: 50.0,
               ).onInkTap(() {
                 assetsAudioPlayer.stop();
                 setState(() {
                   isPlaying = false;
                 });
               }),
             ].vStack(),
          ).pOnly(bottom: context.percentHeight * 12),
        ],
      ),
    );
  }
}
