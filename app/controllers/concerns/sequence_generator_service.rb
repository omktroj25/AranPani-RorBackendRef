module SequenceGeneratorService
    def sequence_generator(model)
        @sequence_generator=SequenceGenerator.find_by(model:model)
        seq=@sequence_generator.seq_no
        @sequence_generator.update!(seq_no:seq+1)
        return seq
    end
end

