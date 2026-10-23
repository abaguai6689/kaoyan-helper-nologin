import 'package:dio/dio.dart';

/// 本地演示数据拦截器。
///
/// 免登录版本没有真实后端凭据，默认启用离线演示数据：
/// 在 Dio 请求真正发出前直接返回一份结构合法的后端 envelope，
/// 从而让看板、刷题、错题、择校、背诵等页面在无网络/无后端时依旧可用。
///
/// 关闭方式：构建时传入 `--dart-define=DEMO_MODE=false`，
/// 此时请求会按 [ApiConfig.baseUrl] 发往后端。
class DemoApiInterceptor extends Interceptor {
  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    final path = _normalizePath(options.uri.path);
    final method = options.method.toUpperCase();
    final data = _DemoStore.instance.handle(
      method: method,
      path: path,
      body: options.data,
    );

    if (data == null) {
      handler.next(options);
      return;
    }

    handler.resolve(
      Response<dynamic>(requestOptions: options, statusCode: 200, data: data),
    );
  }

  static String _normalizePath(String path) {
    var result = path;
    const prefix = '/api/v1';
    if (result.startsWith(prefix)) {
      result = result.substring(prefix.length);
    }
    if (result.isEmpty) {
      return '/';
    }
    return result;
  }
}

class _DemoStore {
  _DemoStore._();

  static final _DemoStore instance = _DemoStore._();

  DateTime get _now => DateTime.now();

  String get _nowIso => _now.toIso8601String();

  String _daysAgoIso(int days) =>
      _now.subtract(Duration(days: days)).toIso8601String();

  late final List<Map<String, dynamic>> _questions = [
    _question(
      id: 'q-1',
      subject: 'politics',
      chapter: '马克思主义基本原理',
      year: 2024,
      stem: '下列关于矛盾普遍性和特殊性关系的表述，正确的是：',
      options: const [
        {'key': 'A', 'content': '矛盾普遍性寓于特殊性之中'},
        {'key': 'B', 'content': '矛盾特殊性可以脱离普遍性独立存在'},
        {'key': 'C', 'content': '矛盾普遍性包含矛盾特殊性'},
        {'key': 'D', 'content': '矛盾的同一性是绝对的，斗争性是相对的'},
      ],
      answer: 'A',
      explanation: '矛盾的普遍性即矛盾的共性，矛盾的特殊性即矛盾的个性。共性寓于个性之中。',
    ),
    _question(
      id: 'q-2',
      subject: 'politics',
      chapter: '中国近现代史纲要',
      year: 2023,
      stem: '标志着中国共产党在政治上开始走向成熟的会议是：',
      options: const [
        {'key': 'A', 'content': '中共二大'},
        {'key': 'B', 'content': '八七会议'},
        {'key': 'C', 'content': '遵义会议'},
        {'key': 'D', 'content': '中共七大'},
      ],
      answer: 'C',
      explanation: '遵义会议在事实上确立了以毛泽东同志为核心的党中央的正确领导，标志着党在政治上开始走向成熟。',
    ),
    _question(
      id: 'q-3',
      subject: 'english',
      chapter: '阅读理解',
      year: 2024,
      stem: 'According to the passage, the author believes that technological progress ____.',
      options: const [
        {'key': 'A', 'content': 'is always beneficial to society'},
        {'key': 'B', 'content': 'should be guided by human values'},
        {'key': 'C', 'content': 'has solved most social problems'},
        {'key': 'D', 'content': 'is independent of public policy'},
      ],
      answer: 'B',
      explanation: '作者在末段强调技术进步必须以人为本，需要价值观与公共政策的引导，故选 B。',
    ),
    _question(
      id: 'q-4',
      subject: 'math',
      chapter: '线性代数',
      year: 2024,
      stem: '设 A 为 3 阶可逆矩阵，且 |A| = 2，则 |2A⁻¹| = ?',
      options: const [
        {'key': 'A', 'content': '1'},
        {'key': 'B', 'content': '2'},
        {'key': 'C', 'content': '4'},
        {'key': 'D', 'content': '8'},
      ],
      answer: 'C',
      explanation: '|2A⁻¹| = 2³ · |A⁻¹| = 8 × 1/2 = 4。',
    ),
  ];

  late final List<Map<String, dynamic>> _mistakes = [
    _mistake(
      id: 'm-1',
      status: 'active',
      subject: 'politics',
      stem: '下列关于矛盾普遍性和特殊性关系的表述，正确的是：',
      options: const [
        {'key': 'A', 'content': '矛盾普遍性寓于特殊性之中'},
        {'key': 'B', 'content': '矛盾特殊性可以脱离普遍性独立存在'},
        {'key': 'C', 'content': '矛盾普遍性包含矛盾特殊性'},
        {'key': 'D', 'content': '矛盾的同一性是绝对的，斗争性是相对的'},
      ],
      correctAnswer: 'A',
      explanation: '矛盾的普遍性即矛盾的共性。',
      errorCount: 3,
      consecutiveCorrect: 0,
      hoursAgo: 2,
    ),
    _mistake(
      id: 'm-2',
      status: 'active',
      subject: 'english',
      stem: 'According to the passage, the primary reason for environmental changes is not merely natural shifts but ______.',
      options: const [
        {'key': 'A', 'content': 'human activities'},
        {'key': 'B', 'content': 'climate cycles'},
        {'key': 'C', 'content': 'ocean currents'},
        {'key': 'D', 'content': 'solar radiation'},
      ],
      correctAnswer: 'A',
      explanation: '文章首段明确指出人类活动是环境变化的主要驱动因素。',
      errorCount: 2,
      consecutiveCorrect: 1,
      hoursAgo: 20,
    ),
    _mistake(
      id: 'm-3',
      status: 'active',
      subject: 'professional',
      stem: '在具有 n 个顶点的连通无向图中，其生成树的边数必须为：',
      options: const [
        {'key': 'A', 'content': 'n'},
        {'key': 'B', 'content': 'n - 1'},
        {'key': 'C', 'content': 'n + 1'},
        {'key': 'D', 'content': '2n'},
      ],
      correctAnswer: 'B',
      explanation: 'n 个顶点的树恰有 n - 1 条边，生成树是包含全部顶点的极小连通子图。',
      errorCount: 4,
      consecutiveCorrect: 0,
      hoursAgo: 72,
    ),
  ];

  late final List<Map<String, dynamic>> _schools = [
    _school(
      id: 'school-zju',
      name: '浙江大学',
      province: '浙江省',
      region: '华东',
      is985: true,
      is211: true,
      isDoubleFirstClass: true,
      isSelfMarking: true,
    ),
    _school(
      id: 'school-ecnu',
      name: '华东师范大学',
      province: '上海市',
      region: '华东',
      is985: true,
      is211: true,
      isDoubleFirstClass: true,
      isSelfMarking: false,
    ),
    _school(
      id: 'school-hust',
      name: '华中科技大学',
      province: '湖北省',
      region: '华中',
      is985: true,
      is211: true,
      isDoubleFirstClass: true,
      isSelfMarking: false,
    ),
    _school(
      id: 'school-xdu',
      name: '西安电子科技大学',
      province: '陕西省',
      region: '西北',
      is985: false,
      is211: true,
      isDoubleFirstClass: true,
      isSelfMarking: false,
    ),
  ];

  late final List<Map<String, dynamic>> _programs = [
    _program('p-zju-2024', 'school-zju', '085404', '计算机技术', 2024, 45, 382, 390),
    _program('p-zju-2023', 'school-zju', '085404', '计算机技术', 2023, 40, 375, 383),
    _program('p-zju-2022', 'school-zju', '085404', '计算机技术', 2022, 38, 368, 376),
    _program(
      'p-ecnu-2024',
      'school-ecnu',
      '085400',
      '软件工程',
      2024,
      60,
      355,
      362,
    ),
    _program(
      'p-ecnu-2023',
      'school-ecnu',
      '085400',
      '软件工程',
      2023,
      55,
      348,
      356,
    ),
    _program(
      'p-hust-2024',
      'school-hust',
      '085404',
      '计算机技术',
      2024,
      50,
      370,
      379,
    ),
    _program('p-xdu-2024', 'school-xdu', '085404', '计算机技术', 2024, 70, 340, 350),
  ];

  final List<Map<String, dynamic>> _targets = [
    _target('school-zju', '浙江大学', 'primary', '085404', '计算机技术'),
  ];

  List<Map<String, dynamic>> _dueCards = [
    _dueCard('c-1', '英语大纲高频核心词', 'abandon', 'v. 放弃，遗弃；离弃'),
    _dueCard('c-2', '英语大纲高频核心词', 'vulnerable', 'adj. 易受伤害的，脆弱的；有弱点的'),
    _dueCard('c-3', '英语大纲高频核心词', 'arbitrary', 'adj. 任意的，专断的，随心所欲的'),
  ];

  int _streakDays = 12;

  Map<String, dynamic>? handle({
    required String method,
    required String path,
    Object? body,
  }) {
    final segments = path.split('/').where((part) => part.isNotEmpty).toList();

    if (path == '/dashboard/summary') {
      return _success({
        'daysUntilExam': 98,
        'todayQuestionCount': 32,
        'activeMistakeCount': _mistakes.length,
        'dueCardCount': _dueCards.length,
        'streakDays': _streakDays,
        'totalReviewedCards': 316,
        'primaryTarget': {
          'schoolId': 'school-zju',
          'schoolName': '浙江大学',
          'majorCode': '085404',
          'majorName': '计算机技术',
        },
      });
    }

    if (path == '/me' && method == 'GET') {
      return _success(_mePayload());
    }

    if (path == '/me' && method == 'PATCH') {
      return _success(_mePayload());
    }

    if (path == '/me/targets') {
      if (method == 'PATCH') {
        final list = body is Map<String, dynamic> ? body['targets'] : null;
        if (list is List) {
          _targets
            ..clear()
            ..addAll(
              list.whereType<Map<String, dynamic>>().map((item) {
                final schoolId = item['schoolId'] as String? ?? '';
                final school = _schools.firstWhere(
                  (s) => s['id'] == schoolId,
                  orElse: () => _schools.first,
                );
                return _target(
                  schoolId,
                  school['name'] as String,
                  item['type'] as String? ?? 'backup',
                  item['majorCode'] as String?,
                  item['majorName'] as String?,
                );
              }),
            );
        }
      }
      return _success({'targets': _targets});
    }

    if (segments.isNotEmpty && segments.first == 'questions') {
      return _handleQuestions(method, segments, body);
    }

    if (segments.isNotEmpty && segments.first == 'mistakes') {
      return _handleMistakes(method, segments, body);
    }

    if (segments.isNotEmpty && segments.first == 'flashcards') {
      return _handleFlashcards(method, segments, body);
    }

    if (path == '/check-ins') {
      return _success({
        'items': [
          for (var i = 0; i < 7; i++)
            {
              'checkInDate': _now
                  .subtract(Duration(days: i))
                  .toIso8601String()
                  .substring(0, 10),
              'createdAt': _daysAgoIso(i),
            },
        ],
        'streakDays': _streakDays,
      });
    }

    if (segments.isNotEmpty && segments.first == 'schools') {
      return _handleSchools(method, segments, body);
    }

    // 其它未知接口：返回空成功响应，避免离线时整页报错。
    return _success(<String, dynamic>{});
  }

  Map<String, dynamic>? _handleQuestions(
    String method,
    List<String> segments,
    Object? body,
  ) {
    if (segments.length == 1 && method == 'GET') {
      return _success({
        'items': [
          for (final question in _questions) _questionSummary(question),
        ],
      }, total: _questions.length);
    }

    if (segments.length == 1 && method == 'POST') {
      return _success(_questions.first);
    }

    final id = segments[1];

    if (segments.length == 3 && segments[2] == 'answer' && method == 'POST') {
      final question = _questions.firstWhere(
        (q) => q['id'] == id,
        orElse: () => _questions.first,
      );
      final answer = body is Map<String, dynamic> ? body['answer'] : null;
      final correctAnswer = question['answer'] as String? ?? 'A';
      final isCorrect = answer == correctAnswer;

      if (!isCorrect) {
        _addMistakeFromQuestion(question);
      }

      return _success({
        'isCorrect': isCorrect,
        'correctAnswer': correctAnswer,
        'explanation': question['explanation'],
        'mistake': isCorrect ? null : {'id': 'm-new'},
        'answeredAt': _nowIso,
      });
    }

    if (segments.length == 2 && method == 'GET') {
      return _success(
        _questions.firstWhere(
          (q) => q['id'] == id,
          orElse: () => _questions.first,
        ),
      );
    }

    return _success(<String, dynamic>{});
  }

  Map<String, dynamic>? _handleMistakes(
    String method,
    List<String> segments,
    Object? body,
  ) {
    if (segments.length == 1 && method == 'GET') {
      return _success({'items': _mistakes}, total: _mistakes.length);
    }

    if (segments.length == 1 && method == 'POST') {
      return _success(_mistakes.first);
    }

    final id = segments[1];
    final mistake = _mistakes.firstWhere(
      (m) => m['id'] == id,
      orElse: () => _mistakes.first,
    );

    if (segments.length == 3 && segments[2] == 'redo' && method == 'POST') {
      final answer = body is Map<String, dynamic> ? body['answer'] : null;
      final isCorrect = answer == mistake['correctAnswer'];
      final consecutive =
          (mistake['consecutiveCorrect'] as int) + (isCorrect ? 1 : 0);
      final errorCount = (mistake['errorCount'] as int) + (isCorrect ? 0 : 1);
      final mastered = consecutive >= 2;
      mistake
        ..['consecutiveCorrect'] = consecutive
        ..['errorCount'] = errorCount
        ..['status'] = mastered ? 'mastered' : 'active'
        ..['lastWrongAt'] = isCorrect ? mistake['lastWrongAt'] : _nowIso;

      return _success({
        'isCorrect': isCorrect,
        'correctAnswer': mistake['correctAnswer'],
        'explanation': mistake['explanation'],
        'mistake': mistake,
        'mastered': mastered,
        'answeredAt': _nowIso,
      });
    }

    if (segments.length == 3 && segments[2] == 'status' && method == 'PATCH') {
      final status = body is Map<String, dynamic>
          ? body['status'] as String?
          : null;
      if (status != null) {
        mistake
          ..['status'] = status
          ..['consecutiveCorrect'] = 0;
      }
      return _success(mistake);
    }

    if (segments.length == 2 && method == 'GET') {
      return _success(mistake);
    }

    if (segments.length == 2 && method == 'DELETE') {
      _mistakes.removeWhere((m) => m['id'] == id);
      return _success(<String, dynamic>{});
    }

    return _success(<String, dynamic>{});
  }

  Map<String, dynamic>? _handleFlashcards(
    String method,
    List<String> segments,
    Object? body,
  ) {
    if (segments.length == 1 && method == 'GET') {
      return _success({
        'items': [for (final card in _dueCards) card['card']],
      }, total: _dueCards.length);
    }

    if (segments.length == 2 && segments[1] == 'due' && method == 'GET') {
      return _success({
        'items': _dueCards,
        'dueRemaining': _dueCards.length,
        'serverTime': _nowIso,
      });
    }

    if (segments.length == 1 && method == 'POST') {
      return _success(
        body is Map<String, dynamic>
            ? {
                'id': 'c-new',
                'source': 'user',
                'category': body['category'] ?? '自建卡片',
                'front': body['front'] ?? '',
                'back': body['back'] ?? '',
                'tags': body['tags'] ?? const <String>[],
                'isMine': true,
                'createdAt': _nowIso,
              }
            : <String, dynamic>{},
      );
    }

    if (segments.length == 3 && segments[2] == 'review' && method == 'POST') {
      final id = segments[1];
      _dueCards = _dueCards.where((item) {
        final card = item['card'] as Map<String, dynamic>;
        return card['id'] != id;
      }).toList();
      _streakDays += 1;

      return _success({
        'progress': {
          'repetitions': 3,
          'intervalDays': 7,
          'easeFactor': 2.6,
          'dueAt': _now.add(const Duration(days: 7)).toIso8601String(),
          'lastRating': body is Map<String, dynamic>
              ? body['rating']
              : 'remembered',
        },
        'dueRemaining': _dueCards.length,
        'checkIn': _dueCards.isEmpty
            ? {'checkInDate': _nowIso.substring(0, 10)}
            : null,
      });
    }

    return _success(<String, dynamic>{});
  }

  Map<String, dynamic>? _handleSchools(
    String method,
    List<String> segments,
    Object? body,
  ) {
    if (segments.length == 1 && method == 'GET') {
      return _success({'items': _schools}, total: _schools.length);
    }

    final id = segments[1];

    if (segments.length == 2 && method == 'GET') {
      final school = _schools.firstWhere(
        (s) => s['id'] == id,
        orElse: () => _schools.first,
      );
      return _success({
        ...school,
        'majors': [
          {'majorCode': '085404', 'majorName': '计算机技术'},
          {'majorCode': '085400', 'majorName': '软件工程'},
        ],
      });
    }

    if (segments.length == 3 && segments[2] == 'programs' && method == 'GET') {
      final programs = _programs.where((p) => p['schoolId'] == id).toList();
      return _success({'items': programs}, total: programs.length);
    }

    if (segments.length == 3 && segments[2] == 'target') {
      final type = body is Map<String, dynamic>
          ? body['type'] as String? ?? 'primary'
          : 'primary';

      if (method == 'POST') {
        final school = _schools.firstWhere(
          (s) => s['id'] == id,
          orElse: () => _schools.first,
        );
        _targets.removeWhere((t) => t['type'] == type);
        _targets.add(
          _target(
            id,
            school['name'] as String,
            type,
            body is Map<String, dynamic> ? body['majorCode'] as String? : null,
            body is Map<String, dynamic> ? body['majorName'] as String? : null,
          ),
        );
      } else if (method == 'DELETE') {
        _targets.removeWhere((t) => t['schoolId'] == id && t['type'] == type);
      }

      return _success({'targets': _targets});
    }

    return _success(<String, dynamic>{});
  }

  void _addMistakeFromQuestion(Map<String, dynamic> question) {
    final id = 'm-${question['id']}';
    if (_mistakes.any((m) => m['id'] == id)) {
      return;
    }
    _mistakes.add(
      _mistake(
        id: id,
        status: 'active',
        subject: question['subject'] as String? ?? 'politics',
        stem: question['stem'] as String? ?? '',
        options: question['options'] as List<Map<String, dynamic>>,
        correctAnswer: question['answer'] as String? ?? 'A',
        explanation: question['explanation'] as String?,
        errorCount: 1,
        consecutiveCorrect: 0,
        hoursAgo: 0,
      ),
    );
  }

  Map<String, dynamic> _mePayload() {
    return {
      'user': {
        'id': 'demo-user-001',
        'email': 'demo@kaoyan.local',
        'nickname': '登科研友',
        'role': 'user',
        'isBanned': false,
        'examYear': 2027,
      },
      'targets': _targets,
    };
  }

  Map<String, dynamic> _success(Map<String, dynamic> data, {int? total}) {
    return {
      'success': true,
      'data': data,
      if (total != null)
        'meta': {
          'pagination': {
            'page': 1,
            'pageSize': 50,
            'total': total,
            'totalPages': 1,
          },
        },
    };
  }
}

Map<String, dynamic> _question({
  required String id,
  required String subject,
  required String chapter,
  required int year,
  required String stem,
  required List<Map<String, dynamic>> options,
  required String answer,
  required String explanation,
}) {
  return {
    'id': id,
    'subject': subject,
    'chapter': chapter,
    'year': year,
    'type': 'single_choice',
    'stem': stem,
    'options': options,
    'difficulty': 'medium',
    'source': 'official',
    'isPublic': true,
    'isApproved': true,
    'reviewStatus': 'approved',
    'isMine': false,
    'createdAt': DateTime.now()
        .subtract(const Duration(days: 30))
        .toIso8601String(),
    'answer': answer,
    'explanation': explanation,
    'version': 1,
  };
}

Map<String, dynamic> _questionSummary(Map<String, dynamic> question) {
  return {
    'id': question['id'],
    'subject': question['subject'],
    'chapter': question['chapter'],
    'year': question['year'],
    'type': question['type'],
    'stem': question['stem'],
    'options': question['options'],
    'difficulty': question['difficulty'],
    'source': question['source'],
    'isPublic': question['isPublic'],
    'isApproved': question['isApproved'],
    'reviewStatus': question['reviewStatus'],
    'isMine': question['isMine'],
    'createdAt': question['createdAt'],
  };
}

Map<String, dynamic> _mistake({
  required String id,
  required String status,
  required String subject,
  required String stem,
  required List<Map<String, dynamic>> options,
  required String correctAnswer,
  required String? explanation,
  required int errorCount,
  required int consecutiveCorrect,
  required int hoursAgo,
}) {
  final now = DateTime.now();
  final lastWrongAt = now.subtract(Duration(hours: hoursAgo));

  return {
    'id': id,
    'status': status,
    'errorCount': errorCount,
    'consecutiveCorrect': consecutiveCorrect,
    'lastWrongAt': lastWrongAt.toIso8601String(),
    'createdAt': now.subtract(const Duration(days: 10)).toIso8601String(),
    'updatedAt': lastWrongAt.toIso8601String(),
    'question': {
      'id': 'question-$id',
      'subject': subject,
      'chapter': '核心考点',
      'type': 'single_choice',
      'stem': stem,
      'options': options,
    },
    'correctAnswer': correctAnswer,
    'explanation': explanation,
    'version': 1,
  };
}

Map<String, dynamic> _school({
  required String id,
  required String name,
  required String province,
  required String region,
  required bool is985,
  required bool is211,
  required bool isDoubleFirstClass,
  required bool isSelfMarking,
}) {
  return {
    'id': id,
    'name': name,
    'province': province,
    'region': region,
    'is985': is985,
    'is211': is211,
    'isDoubleFirstClass': isDoubleFirstClass,
    'isSelfMarking': isSelfMarking,
    'createdAt': DateTime.now()
        .subtract(const Duration(days: 365))
        .toIso8601String(),
  };
}

Map<String, dynamic> _program(
  String id,
  String schoolId,
  String majorCode,
  String majorName,
  int year,
  int planEnrollment,
  int minScore,
  int avgScore,
) {
  return {
    'id': id,
    'schoolId': schoolId,
    'majorCode': majorCode,
    'majorName': majorName,
    'year': year,
    'studyMode': '全日制',
    'planEnrollment': planEnrollment,
    'minScore': minScore,
    'avgScore': avgScore,
  };
}

Map<String, dynamic> _target(
  String schoolId,
  String schoolName,
  String type,
  String? majorCode,
  String? majorName,
) {
  return {
    'schoolId': schoolId,
    'schoolName': schoolName,
    'type': type,
    'majorCode': majorCode,
    'majorName': majorName,
    'updatedAt': DateTime.now().toIso8601String(),
  };
}

Map<String, dynamic> _dueCard(
  String id,
  String category,
  String front,
  String back,
) {
  return {
    'card': {
      'id': id,
      'source': 'system',
      'category': category,
      'front': front,
      'back': back,
      'tags': const <String>['考研', '高频'],
      'isMine': false,
      'createdAt': DateTime.now()
          .subtract(const Duration(days: 5))
          .toIso8601String(),
    },
    'progress': {
      'repetitions': 2,
      'intervalDays': 3,
      'easeFactor': 2.5,
      'dueAt': DateTime.now()
          .subtract(const Duration(hours: 1))
          .toIso8601String(),
      'lastRating': 'remembered',
    },
  };
}
