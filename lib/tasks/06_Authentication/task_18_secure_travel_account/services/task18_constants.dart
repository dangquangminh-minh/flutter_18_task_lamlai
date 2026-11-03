
class Task18Constants {
  static const rootPath='/task_18_secure_travel';
  static const loginPath='$rootPath/login';
  static const accountPath='$rootPath/account';
  static const offlinePath='$rootPath/offline';

  static const secureBoxName='task18_secure_travel_box';
  static const secureKeyName='task18_hive_aes_key';
  static const sessionUidKey='task18_session_uid';
  static const lastAuthAtKey='task18_last_auth_at';

  static const favoriteCodeKey='favorite_country_code';
  static const profileKey='profile';
  static const countryKey='favorite_country';
  static const weatherKey='favorite_weather';
  static const updatedAtKey='updated_at';

  static const staleAfter=Duration(hours:24);
}
