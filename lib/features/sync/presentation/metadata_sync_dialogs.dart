import 'package:flutter/material.dart';
import 'package:nostalgia/features/sync/data/metadata_sync_service.dart';

Future<bool> showMetadataSyncConfirmDialog(
  BuildContext context, {
  required MetadataSyncDryRunResult preview,
  bool syncSamsungFilename = true,
  bool writeExif = true,
}) async {
  final confirmed = await showDialog<bool>(
    context: context,
    builder: (context) => AlertDialog(
      title: const Text('메타데이터 & 검색 동기화'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('동기화 대상: ${preview.targetCount}개'),
          if (preview.unsupportedCount > 0)
            Text('미지원 포맷: ${preview.unsupportedCount}개'),
          if (preview.noFileCount > 0)
            Text('원본 파일 접근 실패: ${preview.noFileCount}개'),
          const Divider(height: 16),
          const Text(
            '🛡️ 안전 보장:',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          const Text('• 원본을 복제하지 않아 중복 저장이 발생하지 않습니다.'),
          const Text('• 동기화 후에도 보류함으로 이동하지 않고 안전하게 보관됩니다.'),
          if (syncSamsungFilename)
            const Text('• 삼성 갤러리 검색 지원: 파일명에 #태그가 안전하게 포함됩니다.'),
          if (writeExif)
            const Text('• 표준 EXIF: UserComment/ImageDescription에 태그가 기록됩니다.'),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(false),
          child: const Text('취소'),
        ),
        FilledButton(
          onPressed: () => Navigator.of(context).pop(true),
          child: const Text('안전 동기화 실행'),
        ),
      ],
    ),
  );
  return confirmed ?? false;
}

Future<void> showMetadataSyncResultDialog(
  BuildContext context, {
  required MetadataSyncRunResult result,
}) async {
  await showDialog<void>(
    context: context,
    builder: (context) => AlertDialog(
      title: const Text('동기화 완료'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('✅ 성공: ${result.syncedOriginalIds.length}개'),
          if (result.renamedFilesCount > 0)
            Text('🏷️ 삼성 갤러리 검색용 파일명 태깅: ${result.renamedFilesCount}개'),
          if (result.failedOriginalIds.isNotEmpty)
            Text('❌ 실패: ${result.failedOriginalIds.length}개'),
          if (result.unsupportedOriginalIds.isNotEmpty)
            Text('⚠️ 미지원 포맷: ${result.unsupportedOriginalIds.length}개'),
          const SizedBox(height: 8),
          const Text(
            '모든 사진이 보관함에 안전하게 유지되었습니다.',
            style: TextStyle(fontSize: 12, color: Colors.grey),
          ),
        ],
      ),
      actions: [
        FilledButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('확인'),
        ),
      ],
    ),
  );
}
