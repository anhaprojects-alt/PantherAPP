<?php

namespace Database\Seeders;

use App\Models\Member;
use App\Models\User;
use Illuminate\Database\Console\Seeds\WithoutModelEvents;
use Illuminate\Database\Seeder;
use Illuminate\Support\Facades\Hash;

class DatabaseSeeder extends Seeder
{
    use WithoutModelEvents;

    /**
     * Seed the application's database.
     *
     * Every seeded account uses the factory password "password". The seeder is
     * idempotent, so re-running it never duplicates the named accounts or the
     * random pending applications.
     */
    public function run(): void
    {
        $this->seedNamedUsers();
        $this->topUpRandomMembers(target: 2);
    }

    /**
     * Create (or reuse) the fixed demo accounts and their membership.
     */
    private function seedNamedUsers(): void
    {
        $testUser = User::firstOrCreate(
            ['email' => 'test@example.com'],
            ['name' => 'Test User', 'password' => Hash::make('password')],
        );

        if (! $testUser->member()->exists()) {
            Member::factory()->approved()->for($testUser)->create();
        }

        $admin = User::firstOrCreate(
            ['email' => 'admin@panther.test'],
            ['name' => 'Panther Admin', 'password' => Hash::make('password')],
        );

        if (! $admin->is_admin) {
            $admin->forceFill(['is_admin' => true])->save();
        }
    }

    /**
     * Ensure the number of pending applications reaches the target without
     * creating extra rows on repeated runs.
     */
    private function topUpRandomMembers(int $target): void
    {
        $missing = $target - Member::query()->pending()->count();

        if ($missing > 0) {
            Member::factory()->count($missing)->create();
        }
    }
}
