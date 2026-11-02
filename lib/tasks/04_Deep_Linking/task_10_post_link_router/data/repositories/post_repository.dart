
import '../../domain/models/post_model.dart';
import '../datasources/post_remote_data_source.dart';

class PostRepository {
  PostRepository({
    required PostRemoteDataSource remote,
  }) : _remote = remote;

  final PostRemoteDataSource _remote;

  Future<PostModel> getPost(int id) {

    return _remote.getPost(id);
  }

  Future<List<PostModel>> getSamplePosts() {
    // id  demo deep link
    return _remote.getPosts(

      const [12, 15, 24, 38],
      
    );
  }
}