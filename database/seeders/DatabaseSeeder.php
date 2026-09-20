<?php

namespace Database\Seeders;

use App\Models\Member;
use App\Models\User;
use Illuminate\Database\Console\Seeds\WithoutModelEvents;
use Illuminate\Database\Seeder;

class DatabaseSeeder extends Seeder
{
    use WithoutModelEvents;

    /**
     * Seed the application's database.
     *
     * Every seeded account uses the factory password "password".
     */
    public function run(): void
    {
        Member::factory()
            ->approved()
            ->for(User::factory()->create([
                'name' => 'Test User',
                'email' => 'test@example.com',
            ]))
            ->create();

        User::factory()->admin()->create([
            'name' => 'Panther Admin',
            'email' => 'admin@panther.test',
        ]);

        Member::factory()->count(2)->create();
    }
}
