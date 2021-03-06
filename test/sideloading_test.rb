
describe 'ArraySerializer patch' do
  let(:json_data)  { ActiveModel::Serializer.build_json(controller, relation, options).to_json }
  let(:options)    { }

  context 'no where clause on root relation' do
    let(:relation)   { Note.all }
    let(:controller) { NotesController.new }

    before do
      note_1 = Note.create name: 'test', content: 'dummy content'
      note_2 = Note.create name: 'test 2', content: 'dummy content'

      tag    = Tag.create name: 'tag 1', note_id: note_1.id
      Tag.create name: 'tag 2'
      @json_expected = "{\"notes\":[{\"id\":#{note_1.id},\"content\":\"dummy content\",\"name\":\"test\",\"tag_ids\":[#{tag.id}]}, \n {\"id\":#{note_2.id},\"content\":\"dummy content\",\"name\":\"test 2\",\"tag_ids\":[]}],\"tags\":[{\"id\":#{tag.id},\"name\":\"tag 1\",\"note_id\":#{note_1.id}}]}"
    end

    it 'generates the proper json output for the serializer' do
      json_data.must_equal @json_expected
    end

    it 'does not instantiate ruby objects for relations' do
      relation.stub(:to_a,
                    -> { raise Exception.new('#to_a should never be called') }) do
        json_data
      end
    end
  end

  context 'where clause on root relation' do
    let(:relation)   { Note.where(name: 'test') }
    let(:controller) { NotesController.new }

    before do
      note_1 = Note.create name: 'test', content: 'dummy content'
      note_2 = Note.create name: 'test 2', content: 'dummy content'

      tag    = Tag.create name: 'tag 1', note_id: note_1.id
      Tag.create name: 'tag 2', note_id: note_2.id
      @json_expected = "{\"notes\":[{\"id\":#{note_1.id},\"content\":\"dummy content\",\"name\":\"test\",\"tag_ids\":[#{tag.id}]}],\"tags\":[{\"id\":#{tag.id},\"name\":\"tag 1\",\"note_id\":#{note_1.id}}]}"
    end

    it 'generates the proper json output for the serializer' do
      json_data.must_equal @json_expected
    end

    it 'does not instantiate ruby objects for relations' do
      relation.stub(:to_a,
                    -> { raise Exception.new('#to_a should never be called') }) do
        json_data
      end
    end
  end

  context 'root relation has belongs_to association' do
    let(:relation)   { Tag.all }
    let(:controller) { TagController.new }
    let(:options)    { { each_serializer: TagWithNoteSerializer } }

    before do
      note = Note.create content: 'Test', name: 'Title'
      tag = Tag.create name: 'My tag', note: note
      @json_expected = "{\"tags\":[{\"id\":#{tag.id},\"name\":\"My tag\",\"note_id\":#{note.id}}],\"notes\":[{\"id\":#{note.id},\"content\":\"Test\",\"name\":\"Title\",\"tag_ids\":[#{tag.id}]}]}"
    end

    it 'generates the proper json output for the serializer' do
      json_data.must_equal @json_expected
    end

    it 'does not instantiate ruby objects for relations' do
      relation.stub(:to_a,
                    -> { raise Exception.new('#to_a should never be called') }) do
        json_data
      end
    end
  end

  context 'relation has multiple associates to the same table' do
    let(:relation)   { User.all }
    let(:controller) { UserController.new }

    before do
      user = User.create name: 'John'
      reviewer = User.create name: 'Peter'
      offer = Offer.create created_by: user, reviewed_by: reviewer
      @json_expected = "{\"users\":[{\"id\":#{reviewer.id},\"name\":\"Peter\",\"offer_ids\":[],\"reviewed_offer_ids\":[#{offer.id}]}, \n {\"id\":#{user.id},\"name\":\"John\",\"offer_ids\":[#{offer.id}],\"reviewed_offer_ids\":[]}],\"offers\":[{\"id\":#{offer.id}}]}"
    end

    it 'generates the proper json output for the serializer' do
      json_data.must_equal @json_expected
    end

    it 'does not instantiate ruby objects for relations' do
      relation.stub(:to_a,
                    -> { raise Exception.new('#to_a should never be called') }) do
        json_data
      end
    end
  end

  context 'empty data should return empty array not null' do
    let(:relation)   { Tag.all }
    let(:controller) { TagController.new }
    let(:options)    { { each_serializer: TagWithNoteSerializer } }

    before do
      @json_expected = "{\"tags\":[],\"notes\":[]}"
    end

    it 'generates the proper json output for the serializer' do
      json_data.must_equal @json_expected
    end

    it 'does not instantiate ruby objects for relations' do
      relation.stub(:to_a,
                    -> { raise Exception.new('#to_a should never be called') }) do
        json_data
      end
    end
  end

  context 'nested filtering support' do
    let(:relation)   { Tag.where(note: { name: 'Title' }) }
    let(:controller) { TagController.new }

    before do
      note = Note.create content: 'Test', name: 'Title'
      tag = Tag.create name: 'My tag', note: note
      @json_expected = ""
    end

    it 'generates the proper json output for the serializer' do
      skip('to be fixed')
      json_data.must_equal @json_expected
    end

    it 'does not instantiate ruby objects for relations' do
      skip('to be fixed')
      relation.stub(:to_a,
                    -> { raise Exception.new('#to_a should never be called') }) do
        json_data
      end
    end
  end
end
