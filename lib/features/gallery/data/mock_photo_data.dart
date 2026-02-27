import 'package:nostalgia/features/gallery/domain/photo_item.dart';

const List<PhotoItem> mockPhotos = [
  PhotoItem(
    id: 'mock-1',
    title: 'IMG_4021',
    dateLabel: '2026-02-24',
    sizeBytes: 1829381,
    tags: ['\uC5EC\uD589', '\uBC14\uB2E4'],
  ),
  PhotoItem(
    id: 'mock-2',
    title: 'Screenshot_0102',
    dateLabel: '2026-02-20',
    sizeBytes: 631245,
    tags: ['\uC2A4\uD06C\uB9B0\uC0F7', '\uC601\uC218\uC99D'],
    isScreenshot: true,
    inReviewBin: true,
  ),
  PhotoItem(
    id: 'mock-3',
    title: 'IMG_3980',
    dateLabel: '2026-02-18',
    sizeBytes: 2731849,
    tags: ['\uAC00\uC871'],
  ),
  PhotoItem(
    id: 'mock-4',
    title: 'Screenshot_chat',
    dateLabel: '2026-02-12',
    sizeBytes: 509120,
    tags: ['\uC2A4\uD06C\uB9B0\uC0F7', '\uCC44\uD305'],
    isScreenshot: true,
    inReviewBin: true,
  ),
  PhotoItem(
    id: 'mock-5',
    title: 'IMG_3912',
    dateLabel: '2026-02-10',
    sizeBytes: 3228120,
    tags: ['\uBB38\uC11C', '\uBCF4\uAD00'],
  ),
];

