import 'package:flutter/material.dart';
enum Direction {Incoming, Outgoing} 

class InviteCard extends StatelessWidget {
  InviteCard(this.direction, this.title, this.subtitle, this.monthDay, this.weekDay, this.startTime);
  final Direction direction;
  final String title;
  final String subtitle;
  final String monthDay;
  final String weekDay;
  final String startTime;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Container(
        height: 120,
        child: Row(
          children: <Widget>[
            Expanded(
              child: Container(
              decoration: const BoxDecoration(color: Colors.blue),
              ),
              flex: 1,
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text("NOME SOBRENOME"),
                    Text("PROFISSÃO E CARGO"),
                    Text("DIA MES - DIA SEMANA"),
                    direction == Direction.Incoming ?
                      Row(
                        children: <Widget>[
                          FlatButton(
                            child: Text("Aceitar"),
                            onPressed: () => {},
                          ),
                          FlatButton(
                            child: Text("Recusar"),
                            onPressed: () => {},
                          )                  
                        ],
                      )
                    :
                    Text("Aguardando Resposta"),
                  ],
                ),
              ),
              flex: 3,
            ),
          ],),
      ),
    );
  }
}