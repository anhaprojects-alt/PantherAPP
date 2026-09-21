<?php

namespace Database\Factories;

use App\Enums\MemberStatus;
use App\Models\Member;
use App\Models\User;
use Illuminate\Database\Eloquent\Factories\Factory;

/**
 * @extends Factory<Member>
 */
class MemberFactory extends Factory
{
    /**
     * Define the model's default state.
     *
     * @return array<string, mixed>
     */
    public function definition(): array
    {
        $folder = $this->faker->uuid();

        return [
            'user_id' => User::factory(),
            'phone' => $this->faker->numerify('08##########'),
            'ktp_number' => $this->faker->numerify('################'),
            'sim_number' => $this->faker->numerify('############'),
            'status' => MemberStatus::Pending,
            'ktp_path' => $folder.'/ktp.jpg',
            'sim_path' => $folder.'/sim.jpg',
            'payment_path' => $folder.'/payment.jpg',
        ];
    }

    /**
     * Indicate that the application was approved.
     */
    public function approved(): static
    {
        return $this->state(fn (array $attributes): array => [
            'status' => MemberStatus::Approved,
            'member_id' => 'PM-'.$this->faker->regexify('[A-Z0-9]{8}'),
            'approved_at' => now(),
        ]);
    }

    /**
     * Indicate that the application was rejected.
     */
    public function rejected(string $reason = 'Dokumen tidak terbaca.'): static
    {
        return $this->state(fn (array $attributes): array => [
            'status' => MemberStatus::Rejected,
            'rejected_at' => now(),
            'rejected_reason' => $reason,
        ]);
    }
}
