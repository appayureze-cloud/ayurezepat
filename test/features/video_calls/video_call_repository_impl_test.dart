import 'package:doctro_patient/features/video_calls/data/video_call_repository_impl.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('parseVideoCallTokenResponse', () {
    test('parses the cn/token field names (matching the old Laravel shape)',
        () {
      final result =
          parseVideoCallTokenResponse({'cn': 'channel-1', 'token': 'tok-1'});

      expect(result.channelName, 'channel-1');
      expect(result.token, 'tok-1');
    });

    test('falls back to channel_name/rtc_token if cn/token are absent', () {
      final result = parseVideoCallTokenResponse(
          {'channel_name': 'channel-2', 'rtc_token': 'tok-2'});

      expect(result.channelName, 'channel-2');
      expect(result.token, 'tok-2');
    });

    test('throws VideoCallException when the response is not a map', () {
      expect(() => parseVideoCallTokenResponse('not a map'),
          throwsA(isA<VideoCallException>()));
    });

    test('throws VideoCallException when channel/token are both missing', () {
      expect(() => parseVideoCallTokenResponse({'unrelated': 'field'}),
          throwsA(isA<VideoCallException>()));
    });
  });
}
