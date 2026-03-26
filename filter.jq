[

.[] as $h |
$h.data.records as $records |
$records[] as $r |
$r.services[] as $s |
$s.consumables as $sc |
$r.staff as $staff |

{
    name: $h.client_name,
    attendance: $r.attendance,
    date: ($r.date | strptime("%Y-%m-%d %H:%M:%S") | strftime("%d.%m.%Y")),
    mounth: ($r.date | strptime("%Y-%m-%d %H:%M:%S") | strftime("%m")),
    year: ($r.date | strptime("%Y-%m-%d %H:%M:%S") | strftime("%Y")),
    time: ($r.date | strptime("%Y-%m-%d %H:%M:%S") | strftime("%H:%M")),
    service_id: $s.id,
    title: $s.title,
    price: $s.payed_cost,
    cost_price: ($sc | map(.cost_per_unit * .amount * -1) | add),
    staff: {
                id: $staff.id,
                name: $staff.name
            }
}

] 



