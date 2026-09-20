<?php

namespace App\Http\Controllers\Admin;

use App\Http\Controllers\Controller;
use App\Models\Member;
use Illuminate\View\View;

class DashboardController extends Controller
{
    /**
     * Overview of the membership queue.
     */
    public function __invoke(): View
    {
        return view('admin.dashboard', [
            'counts' => Member::statusCounts(),
            'latestPending' => Member::query()
                ->with('user')
                ->pending()
                ->latest()
                ->limit(5)
                ->get(),
        ]);
    }
}
