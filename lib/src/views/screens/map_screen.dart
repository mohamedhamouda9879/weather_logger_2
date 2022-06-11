import 'package:conditional_builder_rec/conditional_builder_rec.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:weather_logger/src/core/constants/string_const.dart';
import 'package:weather_logger/src/core/themes/text_styles.dart';
import 'package:weather_logger/src/core/utils/utils.dart';
import 'package:weather_logger/src/features/home/bloc/home_bloc.dart';

class SaveScreen extends StatelessWidget {
  const SaveScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => HomeBloc()
        ..getLocation()
        ..CreateDataBase(),
      child: BlocConsumer<HomeBloc, HomeState>(
        listener: (context, state) {
          if (state is HomeFailed) {
            showSnackBar(context, state.error);
          }
        },
        builder: (context, state) {
          if (state is HomeLoading) {
            return const Loading();
          }
          if (state is HomeSuccess) {
            final weather = state.weatherData;
            var tasks = HomeBloc.get(context).weather;
            return SafeArea(
              child: Scaffold(
                appBar: AppBar(
                    title: Text('Weather Logger'),
                    centerTitle: true,
                    actions: [
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: IconButton(
                          icon: Icon(Icons.save),
                          onPressed: (() {
                            HomeBloc.get(context).insertToDatabase(
                                title: '${weather.current.temp}°',
                                time: weather.timezone,
                                date: weather.timezoneOffset.toString());
                            showSnackBar(context, 'inserted successfully');
                          }),
                        ),
                      )
                    ]),
                body: ConditionalBuilderRec(
                  condition: tasks.length > 0,
                  builder: (context) => ListView.separated(
                    itemBuilder: (context, index) {
                      return buildTaskItem(tasks[index], context);
                    },
                    separatorBuilder: (context, index) => myDivider(),
                    itemCount: tasks.length,
                  ),
                  fallback: (context) => Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.menu,
                          size: 100.0,
                          color: Colors.grey,
                        ),
                        Text(
                          'No Added Yet, Please Add Some Weather',
                          style: TextStyle(
                            fontSize: 16.0,
                            fontWeight: FontWeight.bold,
                            color: Colors.grey,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            );
          }
          if (state is HomeFailed) {
            return SomethingWentWrong(message: state.error);
          }
          if (state is HomeLocationNotEnabled) {
            if (state.error == locationDisabledError) {
              return Center(
                child: Text(
                  'Location services are disabled.\nPlease Restart app after enabling it.',
                  style: subTitleTextStyle(
                      fontSize: 18, fontWeight: FontWeight.w500),
                ),
              );
            }
            return SomethingWentWrong(message: state.error);
          }
          return const SizedBox();
        },
      ),
    );
  }
}

Widget myDivider() => Padding(
      padding: const EdgeInsetsDirectional.only(
        start: 20.0,
      ),
      child: Container(
        width: double.infinity,
        height: 1.0,
        color: Colors.grey[300],
      ),
    );
Widget buildTaskItem(Map model, context) => Dismissible(
      key: Key(model['id'].toString()),
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Row(
          children: [
            CircleAvatar(
              radius: 40.0,
              backgroundColor: Color.fromARGB(255, 221, 194, 96),
              child: Center(
                child: Text(
                  '${model['time']}',
                ),
              ),
            ),
            SizedBox(
              width: 20.0,
            ),
            Expanded(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '${model['title']}',
                    style: TextStyle(
                      fontSize: 18.0,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    '${model['date']}',
                    style: TextStyle(
                      color: Colors.grey,
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(
              width: 20.0,
            ),
          ],
        ),
      ),
    );
