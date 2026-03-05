import 'package:finality/features/activity/widgets/transaction_list_date_header.dart';
import 'package:finality/theme/dimens.dart';
import 'package:flutter/material.dart';
import 'package:skeletonizer/skeletonizer.dart';

class TransactionSliverLoading extends StatelessWidget {
  const TransactionSliverLoading({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemBuilder: (context, index) {
        var dateTime = DateTime.now();
        if (index == 0) {
          return Skeletonizer(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TransactionListDateHeader(
                    dateTime: dateTime, showDivider: false),
                itemForSkeleton(),
              ],
            ),
          );
        }
        return Skeletonizer(child: itemForSkeleton());
      },
      itemCount: 10,
    );
  }

   static Widget itemForSkeleton() {
    return const Padding(
      padding: EdgeInsets.symmetric(vertical: 16, horizontal: 16),
      child: Row(
        children: [
          SizedBox(
            width: 40,
            height: 40,
            child: Center(
              child: Bone.circle(
                size: 38,
              ),
            ),
          ),
          Dimens.hGap16,
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Sold SOL",
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 16,
                  ),
                ),
                SizedBox(height: 1),
                Text(
                  'PM 11:50',
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
          Dimens.hGap16,
          Text(
            '+\$0.0000',
            style: TextStyle(
              fontWeight: FontWeight.w600,
              fontSize: 16,
            ),
          )
        ],
      ),
    );
  }
}
