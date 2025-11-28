import 'package:kaih_7_xirpl2/core/models/habit_models.dart';

class HabitConfig {
  static final List<Habit> sevenHabits = [
    Habit(
      name: 'BangunPagi',
      description: 'Melatih disiplin waktu dan memulai hari dengan lebih siap, segar, dan produktif',
      iconPath: 'assets/images/bangun_pagi_bg.jpg',
      isMultiEntry: false,
    ),
    Habit(
      name: 'Beribadah', 
      description: 'Membentuk karakter yang memiliki nilai spiritual, moral, dan empati yang kuat',
      iconPath: 'assets/images/beribadah_bg.jpg',
      isMultiEntry: true, 
    ),
    Habit(
      name: 'Berolahraga',
      description: 'Menjaga kebugaran fisik dan kesehatan mental, serta membangun kedisiplinan dan sportivitas',
      iconPath: 'assets/images/olahraga_bg.jpg',
      isMultiEntry: false, 
    ),
    Habit(
      name: 'MakanSehat',
      description: 'Memenuhi kebutuhan nutrisi yang optimal untuk tumbuh kembang fisik dan kecerdasan',
      iconPath: 'assets/images/makan_sehat_bg.jpg',
      isMultiEntry: true, 
    ),
    Habit(
      name: 'Belajar',
      description: 'Menumbuhkan rasa ingin tahu, kreativitas, dan mengembangkan kecerdasan intelektual serta emosional',
      iconPath: 'assets/images/baca_buku_bg.jpg',
      isMultiEntry: false,  
    ),
    Habit(
      name: 'Bermasyarakat',
      description: 'Mengajarkan kepedulian, toleransi, dan kemampuan bekerja sama dalam lingkungan sosial',
      iconPath: 'assets/images/bermasyarakat_bg.jpg',
      isMultiEntry: false, 
    ),
    Habit(
      name: 'TidurCepat',
      description: 'Mendapatkan istirahat yang cukup dan berkualitas untuk pemulihan fisik dan mental',
      iconPath: 'assets/images/tidur_cepat_bg.jpg',
      isMultiEntry: false, 
    ),
  ];
}