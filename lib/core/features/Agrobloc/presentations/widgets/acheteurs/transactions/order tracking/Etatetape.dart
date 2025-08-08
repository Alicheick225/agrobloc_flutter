import 'package:flutter/material.dart';

class CardWidget extends StatelessWidget {
  final List<TransactionActor> actors;

  const CardWidget({
    Key? key,
    required this.actors,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: actors.map((actor) => _buildActorCard(actor)).toList(),
    );
  }

  Widget _buildActorCard(TransactionActor actor) {
    return Container(
      margin: EdgeInsets.only(bottom: 16),
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        //borderRadius: BorderRadius.circular(0),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: Row(
        children: [
          Container(
            width: 12,
            height: 12,
            decoration: BoxDecoration(
              color: actor.isCompleted ? Colors.green : Colors.grey,
              shape: BoxShape.circle,
            ),
            child: actor.isCompleted
                ? Icon(Icons.check, color: Colors.white, size: 8)
                : null,
          ),
          SizedBox(width: 1),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      actor.name,
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 16,
                        color: Colors.black,
                      ),
                    ),
                    SizedBox(width: 8),
                    Container(
                      padding: EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(
                        color: Colors.grey[200],
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        actor.role,
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey[600],
                        ),
                      ),
                    ),
                  ],
                ),
                if (actor.organization.isNotEmpty) ...[
                  SizedBox(height: 4),
                  Text(
                    actor.organization,
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[600],
                    ),
                  ),
                ],
                SizedBox(height: 4),
                Text(
                  actor.action,
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.green[700],
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                actor.date,
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey[600],
                ),
              ),
              Text(
                actor.time,
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey[600],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// Modèle de données pour les acteurs de transaction
class TransactionActor {
  final String name;
  final String role;
  final String organization;
  final String action;
  final String date;
  final String time;
  final bool isCompleted;

  TransactionActor({
    required this.name,
    required this.role,
    required this.organization,
    required this.action,
    required this.date,
    required this.time,
    required this.isCompleted,
  });
}
